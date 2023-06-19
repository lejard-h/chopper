///@nodoc
import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:chopper_generator/src/extensions.dart';
import 'package:chopper_generator/src/utils.dart';
import 'package:chopper_generator/src/vars.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

class ChopperGenerator extends GeneratorForAnnotation<chopper.ChopperApi> {
  static final Logger _logger = Logger('Chopper Generator');

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final String friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [ChopperApi] annotation from `$friendlyName`.',
      );
    }

    return _buildChopperApiImplementationClass(annotation, element);
  }

  bool _extendsChopperService(InterfaceType type) =>
      _typeChecker(chopper.ChopperService).isExactlyType(type);

  Field _buildDefinitionTypeMethod(String superType) => Field(
        (method) => method
          ..annotations.add(refer('override'))
          ..name = 'definitionType'
          ..modifier = FieldModifier.final$
          ..assignment = Code(superType),
      );

  String _buildChopperApiImplementationClass(
    ConstantReader annotation,
    ClassElement element,
  ) {
    if (!element.allSupertypes.any(_extendsChopperService)) {
      final String friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: '`$friendlyName` need to extends the [ChopperService] class.',
      );
    }

    final String friendlyName = element.name;
    final String name = '_\$$friendlyName';
    final String baseUrl =
        annotation.peek(Vars.baseUrl.toString())?.stringValue ?? '';

    final Class classBuilder = Class((builder) {
      builder
        ..name = name
        ..extend = refer(friendlyName)
        ..fields.add(_buildDefinitionTypeMethod(friendlyName))
        ..constructors.add(_generateConstructor())
        ..methods.addAll(_parseMethods(element, baseUrl));
    });

    const String ignore = '// ignore_for_file: '
        'always_put_control_body_on_new_line, '
        'always_specify_types, '
        'prefer_const_declarations, '
        'unnecessary_brace_in_string_interps';
    final DartEmitter emitter = DartEmitter();

    return DartFormatter().format('$ignore\n${classBuilder.accept(emitter)}');
  }

  Constructor _generateConstructor() => Constructor(
        (ConstructorBuilder constructorBuilder) {
          constructorBuilder.optionalParameters.add(
            Parameter((paramBuilder) {
              paramBuilder.name = Vars.client.toString();
              paramBuilder.type = refer('${chopper.ChopperClient}?');
            }),
          );

          constructorBuilder.body = Code(
            'if (${Vars.client} == null) return;\n'
            'this.${Vars.client} = ${Vars.client};',
          );
        },
      );

  Iterable<Method> _parseMethods(ClassElement element, String baseUrl) =>
      element.methods
          .where(
            (MethodElement method) =>
                _getMethodAnnotation(method) != null &&
                method.isAbstract &&
                method.returnType.isDartAsyncFuture,
          )
          .map((MethodElement m) => _generateMethod(m, baseUrl));

  Method _generateMethod(MethodElement m, String baseUrl) {
    final ConstantReader? method = _getMethodAnnotation(m);
    final bool multipart = _hasAnnotation(m, chopper.Multipart);
    final ConstantReader? factoryConverter = _getFactoryConverterAnnotation(m);

    final Map<String, ConstantReader> body = _getAnnotation(m, chopper.Body);
    final Map<ParameterElement, ConstantReader> paths =
        _getAnnotations(m, chopper.Path);
    final Map<ParameterElement, ConstantReader> queries =
        _getAnnotations(m, chopper.Query);
    final Map<String, ConstantReader> queryMap =
        _getAnnotation(m, chopper.QueryMap);
    final Map<ParameterElement, ConstantReader> fields =
        _getAnnotations(m, chopper.Field);
    final Map<String, ConstantReader> fieldMap =
        _getAnnotation(m, chopper.FieldMap);
    final Map<ParameterElement, ConstantReader> parts =
        _getAnnotations(m, chopper.Part);
    final Map<String, ConstantReader> partMap =
        _getAnnotation(m, chopper.PartMap);
    final Map<ParameterElement, ConstantReader> fileFields =
        _getAnnotations(m, chopper.PartFile);
    final Map<String, ConstantReader> fileFieldMap =
        _getAnnotation(m, chopper.PartFileMap);

    final Code? headers = _generateHeaders(m, method!);
    final Expression url = _generateUrl(method, paths, baseUrl);
    final DartType? responseType = _getResponseType(m.returnType);
    final DartType? responseInnerType =
        _getResponseInnerType(m.returnType) ?? responseType;

    return Method((MethodBuilder b) {
      b.annotations.add(refer('override'));
      b.name = m.displayName;

      /// We don't support returning null Type
      b.returns = Reference(
        m.returnType.getDisplayString(withNullability: false),
      );

      /// And null Typed parameters
      b.types.addAll(
        m.typeParameters.map(
          (t) => Reference(t.getDisplayString(withNullability: false)),
        ),
      );

      b.requiredParameters.addAll(
        m.parameters
            .where((p) => p.isRequiredPositional)
            .map(Utils.buildRequiredPositionalParam),
      );

      b.optionalParameters.addAll(
        m.parameters
            .where((p) => p.isOptionalPositional)
            .map(Utils.buildOptionalPositionalParam),
      );

      b.optionalParameters.addAll(
        m.parameters.where((p) => p.isNamed).map(Utils.buildNamedParam),
      );

      final List<Code> blocks = [
        declareFinal(Vars.url.toString(), type: refer('Uri'))
            .assign(url)
            .statement,
      ];

      if (queries.isNotEmpty) {
        blocks.add(
          declareFinal(
            Vars.parameters.toString(),
            type: refer('Map<String, dynamic>'),
          ).assign(_generateMap(queries)).statement,
        );
      }

      /// Build an iterable of all the parameters that are nullable
      final Iterable<String> optionalNullableParameters = [
        ...m.parameters.where((p) => p.isOptionalPositional),
        ...m.parameters.where((p) => p.isNamed),
      ].where((el) => el.type.isNullable).map((el) => el.name);

      final bool hasQueryMap = queryMap.isNotEmpty;
      if (hasQueryMap) {
        if (queries.isNotEmpty) {
          blocks.add(refer('${Vars.parameters}.addAll').call(
            [
              /// Check if the parameter is nullable
              optionalNullableParameters.contains(queryMap.keys.first)
                  ? refer(queryMap.keys.first).ifNullThen(refer('const {}'))
                  : refer(queryMap.keys.first),
            ],
          ).statement);
        } else {
          blocks.add(
            declareFinal(
              Vars.parameters.toString(),
              type: refer('Map<String, dynamic>'),
            )
                .assign(
                  /// Check if the parameter is nullable
                  optionalNullableParameters.contains(queryMap.keys.first)
                      ? refer(queryMap.keys.first).ifNullThen(refer('const {}'))
                      : refer(queryMap.keys.first),
                )
                .statement,
          );
        }
      }

      final bool hasQuery = hasQueryMap || queries.isNotEmpty;

      if (headers != null) {
        blocks.add(headers);
      }

      final bool methodOptionalBody = Utils.getMethodOptionalBody(method);
      final String methodName = Utils.getMethodName(method);
      final String methodUrl = Utils.getMethodPath(method);
      bool hasBody = body.isNotEmpty || fields.isNotEmpty;
      if (hasBody) {
        if (body.isNotEmpty) {
          blocks.add(
            declareFinal(Vars.body.toString())
                .assign(refer(body.keys.first))
                .statement,
          );
        } else {
          blocks.add(
            declareFinal(Vars.body.toString())
                .assign(_generateMap(fields))
                .statement,
          );
        }
      }

      final bool hasFieldMap = fieldMap.isNotEmpty;
      if (hasFieldMap) {
        if (hasBody) {
          blocks.add(refer('${Vars.body}.addAll').call(
            [refer(fieldMap.keys.first)],
          ).statement);
        } else {
          blocks.add(
            declareFinal(Vars.body.toString())
                .assign(refer(fieldMap.keys.first))
                .statement,
          );
        }
      }

      hasBody = hasBody || hasFieldMap;

      bool hasParts = multipart && (parts.isNotEmpty || fileFields.isNotEmpty);
      if (hasParts) {
        blocks.add(
          declareFinal(Vars.parts.toString(), type: refer('List<PartValue>'))
              .assign(_generateList(parts, fileFields))
              .statement,
        );
      }

      final bool hasPartMap = multipart && partMap.isNotEmpty;
      if (hasPartMap) {
        if (hasParts) {
          blocks.add(
            refer('${Vars.parts}.addAll').call(
              [refer(partMap.keys.first)],
            ).statement,
          );
        } else {
          blocks.add(
            declareFinal(Vars.parts.toString(), type: refer('List<PartValue>'))
                .assign(refer(partMap.keys.first))
                .statement,
          );
        }
      }

      final bool hasFileFilesMap = multipart && fileFieldMap.isNotEmpty;
      if (hasFileFilesMap) {
        if (hasParts || hasPartMap) {
          blocks.add(
            refer('${Vars.parts}.addAll').call(
              [refer(fileFieldMap.keys.first)],
            ).statement,
          );
        } else {
          blocks.add(
            declareFinal(Vars.parts.toString(), type: refer('List<PartValue>'))
                .assign(refer(fileFieldMap.keys.first))
                .statement,
          );
        }
      }

      hasParts = hasParts || hasPartMap || hasFileFilesMap;

      if (!methodOptionalBody && !hasBody && !hasParts) {
        _logger.warning(
          '$methodName $methodUrl\n'
          'Body is null\n'
          'Use @Body() annotation on your method parameter to provide a body to your request\n'
          '   e.g.: Future<Response> postRequest(@Body() Map body);\n'
          'Or explicitly suppress this warning by setting the optionalBody property\n'
          '   e.g.: @Post(optionalBody: true)',
        );
      }

      final bool useBrackets = Utils.getUseBrackets(method);

      final bool includeNullQueryVars = Utils.getIncludeNullQueryVars(method);

      blocks.add(
        declareFinal(Vars.request.toString(), type: refer('Request'))
            .assign(
              _generateRequest(
                method,
                hasBody: hasBody,
                useQueries: hasQuery,
                useHeaders: headers != null,
                hasParts: hasParts,
                useBrackets: useBrackets,
                includeNullQueryVars: includeNullQueryVars,
              ),
            )
            .statement,
      );

      final Map<String, Expression> namedArguments = {};

      final ConstantReader? requestFactory = factoryConverter?.peek('request');
      if (requestFactory != null) {
        final ExecutableElement? func =
            requestFactory.objectValue.toFunctionValue();
        namedArguments['requestConverter'] = refer(_factoryForFunction(func!));
      }

      final ConstantReader? responseFactory =
          factoryConverter?.peek('response');
      if (responseFactory != null) {
        final ExecutableElement? func =
            responseFactory.objectValue.toFunctionValue();
        namedArguments['responseConverter'] = refer(_factoryForFunction(func!));
      }

      final List<Reference> typeArguments = [];
      if (responseType != null) {
        typeArguments
            .add(refer(responseType.getDisplayString(withNullability: false)));
        typeArguments.add(
          refer(responseInnerType!.getDisplayString(withNullability: false)),
        );
      }

      blocks.add(refer('${Vars.client}.send')
          .call([refer(Vars.request.toString())], namedArguments, typeArguments)
          .returned
          .statement);

      b.body = Block.of(blocks);
    });
  }

  /// TODO: Upgrade to `Element.enclosingElement` when analyzer 6.0.0 is released; in the mean time ignore the deprecation warning
  /// https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/CHANGELOG.md#520
  String _factoryForFunction(FunctionTypedElement function) =>
      // ignore: deprecated_member_use
      function.enclosingElement3 is ClassElement
          // ignore: deprecated_member_use
          ? '${function.enclosingElement3!.name}.${function.name}'
          : function.name!;

  Map<String, ConstantReader> _getAnnotation(MethodElement method, Type type) {
    DartObject? annotation;
    String name = '';

    for (final ParameterElement p in method.parameters) {
      DartObject? a = _typeChecker(type).firstAnnotationOf(p);
      if (annotation != null && a != null) {
        throw Exception(
          'Too many $type annotation for \'${method.displayName}\'',
        );
      } else if (annotation == null && a != null) {
        annotation = a;
        name = p.displayName;
      }
    }

    return annotation == null ? {} : {name: ConstantReader(annotation)};
  }

  Map<ParameterElement, ConstantReader> _getAnnotations(
    MethodElement m,
    Type type,
  ) {
    Map<ParameterElement, ConstantReader> annotation = {};
    for (final ParameterElement p in m.parameters) {
      final DartObject? a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annotation[p] = ConstantReader(a);
      }
    }

    return annotation;
  }

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  ConstantReader? _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final DartObject? annotation = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annotation != null) {
        return ConstantReader(annotation);
      }
    }

    return null;
  }

  ConstantReader? _getFactoryConverterAnnotation(MethodElement method) {
    final DartObject? annotation = _typeChecker(chopper.FactoryConverter)
        .firstAnnotationOf(method, throwOnUnresolved: false);

    return annotation != null ? ConstantReader(annotation) : null;
  }

  bool _hasAnnotation(MethodElement method, Type type) =>
      _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false) !=
      null;

  final List<Type> _methodsAnnotations = const [
    chopper.Get,
    chopper.Post,
    chopper.Delete,
    chopper.Put,
    chopper.Patch,
    chopper.Method,
    chopper.Head,
    chopper.Options,
  ];

  DartType? _genericOf(DartType? type) =>
      type is InterfaceType && type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  DartType? _getResponseType(DartType type) => _genericOf(_genericOf(type));

  DartType? _getResponseInnerType(DartType type) {
    final DartType? generic = _genericOf(type);

    if (generic == null ||
        _typeChecker(Map).isExactlyType(type) ||
        _typeChecker(BuiltMap).isExactlyType(type)) return type;

    // ignore: deprecated_member_use
    if (generic.isDynamic) return null;

    if (_typeChecker(List).isExactlyType(type) ||
        _typeChecker(BuiltList).isExactlyType(type)) return generic;

    return _getResponseInnerType(generic);
  }

  Expression _generateUrl(
    ConstantReader method,
    Map<ParameterElement, ConstantReader> paths,
    String baseUrl,
  ) {
    String path = Utils.getMethodPath(method);
    paths.forEach((p, ConstantReader r) {
      final String name = r.peek('name')?.stringValue ?? p.displayName;
      path = path.replaceFirst('{$name}', '\${${p.displayName}}');
    });

    if (path.startsWith('http://') || path.startsWith('https://')) {
      /// if the request's url is already a fully qualified URL, we can use
      /// as-is and ignore the baseUrl
      return _generateUri(path);
    } else if (path.isEmpty && baseUrl.isEmpty) {
      return _generateUri('');
    } else {
      if (path.isNotEmpty &&
          baseUrl.isNotEmpty &&
          !baseUrl.endsWith('/') &&
          !path.startsWith('/')) {
        return _generateUri('$baseUrl/$path');
      }

      return _generateUri('$baseUrl$path');
    }
  }

  Expression _generateUri(String url) => refer('Uri').newInstanceNamed(
        'parse',
        [literal(url)],
      );

  Expression _generateRequest(
    ConstantReader method, {
    bool hasBody = false,
    bool hasParts = false,
    bool useQueries = false,
    bool useHeaders = false,
    bool useBrackets = false,
    bool includeNullQueryVars = false,
  }) {
    final List<Expression> params = [
      literal(Utils.getMethodName(method)),
      refer(Vars.url.toString()),
      refer('${Vars.client}.${Vars.baseUrl}'),
    ];

    final Map<String, Expression> namedParams = {};

    if (hasBody) {
      namedParams['body'] = refer(Vars.body.toString());
    }

    if (hasParts) {
      namedParams['parts'] = refer(Vars.parts.toString());
      namedParams['multipart'] = literalBool(true);
    }

    if (useQueries) {
      namedParams['parameters'] = refer(Vars.parameters.toString());
    }

    if (useHeaders) {
      namedParams['headers'] = refer(Vars.headers.toString());
    }

    if (useBrackets) {
      namedParams['useBrackets'] = literalBool(useBrackets);
    }

    if (includeNullQueryVars) {
      namedParams['includeNullQueryVars'] = literalBool(includeNullQueryVars);
    }

    return refer('Request').newInstance(params, namedParams);
  }

  Expression _generateMap(Map<ParameterElement, ConstantReader> queries) {
    final Map map = {};
    queries.forEach((ParameterElement p, ConstantReader r) {
      final String name = r.peek('name')?.stringValue ?? p.displayName;
      map[literal(name)] = refer(p.displayName);
    });

    return literalMap(map, refer('String'), refer('dynamic'));
  }

  Expression _generateList(
    Map<ParameterElement, ConstantReader> parts,
    Map<ParameterElement, ConstantReader> fileFields,
  ) {
    final List list = [];
    parts.forEach((p, ConstantReader r) {
      final String name = r.peek('name')?.stringValue ?? p.displayName;
      final List<Expression> params = [
        literal(name),
        refer(p.displayName),
      ];

      list.add(refer(
        'PartValue<${p.type.getDisplayString(
          withNullability: p.type.isNullable,
        )}>',
      ).newInstance(params));
    });
    fileFields.forEach((p, ConstantReader r) {
      final String name = r.peek('name')?.stringValue ?? p.displayName;
      final List<Expression> params = [
        literal(name),
        refer(p.displayName),
      ];

      list.add(
        refer('PartValueFile<${p.type.getDisplayString(
          withNullability: p.type.isNullable,
        )}>')
            .newInstance(params),
      );
    });

    return literalList(list, refer('PartValue'));
  }

  Code? _generateHeaders(MethodElement methodElement, ConstantReader method) {
    final StringBuffer codeBuffer = StringBuffer('')..writeln('{');

    /// Search for @Header anotation in method parameters
    final Map<ParameterElement, ConstantReader> annotations =
        _getAnnotations(methodElement, chopper.Header);

    annotations.forEach((parameter, ConstantReader annotation) {
      final String paramName = parameter.displayName;
      final String name = annotation.peek('name')?.stringValue ?? paramName;

      if (parameter.type.isNullable) {
        codeBuffer.writeln('if ($paramName != null) \'$name\': $paramName,');
      } else {
        codeBuffer.writeln('\'$name\': $paramName,');
      }
    });

    final ConstantReader? headersReader = method.peek('headers');
    if (headersReader == null) return null;

    final Map<DartObject?, DartObject?> methodAnnotations =
        headersReader.mapValue;

    methodAnnotations.forEach((headerName, headerValue) {
      if (headerName != null && headerValue != null) {
        codeBuffer.writeln(
          '\'${headerName.toStringValue()}\': ${literal(headerValue.toStringValue())},',
        );
      }
    });

    codeBuffer.writeln('}');
    final String code = codeBuffer.toString();

    return code == '{\n}\n'
        ? null
        : declareFinal(
            Vars.headers.toString(),
            type: refer('Map<String, String>'),
          ).assign(CodeExpression(Code(code))).statement;
  }
}
