///@nodoc
import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

const String _clientVar = 'client';
const String _baseUrlVar = 'baseUrl';
const String _parametersVar = r'$params';
const String _headersVar = r'$headers';
const String _requestVar = r'$request';
const String _bodyVar = r'$body';
const String _partsVar = r'$parts';
const String _urlVar = r'$url';

final Logger _logger = Logger('Chopper Generator');

class ChopperGenerator extends GeneratorForAnnotation<chopper.ChopperApi> {
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
    final String baseUrl = annotation.peek(_baseUrlVar)?.stringValue ?? '';

    final Class classBuilder = Class((builder) {
      builder
        ..name = name
        ..extend = refer(friendlyName)
        ..fields.add(_buildDefinitionTypeMethod(friendlyName))
        ..constructors.add(_generateConstructor())
        ..methods.addAll(_parseMethods(element, baseUrl));
    });

    final String ignore =
        '// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps';
    final DartEmitter emitter = DartEmitter();

    return DartFormatter().format('$ignore\n${classBuilder.accept(emitter)}');
  }

  Constructor _generateConstructor() => Constructor(
        (ConstructorBuilder constructorBuilder) {
          constructorBuilder.optionalParameters.add(
            Parameter((paramBuilder) {
              paramBuilder.name = _clientVar;
              paramBuilder.type = refer('${chopper.ChopperClient}?');
            }),
          );

          constructorBuilder.body = Code(
            'if ($_clientVar == null) return;\nthis.$_clientVar = $_clientVar;',
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

      // We don't support returning null Type
      b.returns = Reference(
        m.returnType.getDisplayString(withNullability: false),
      );

      // And null Typed parameters
      b.types.addAll(
        m.typeParameters.map(
          (t) => Reference(t.getDisplayString(withNullability: false)),
        ),
      );

      b.requiredParameters.addAll(
        m.parameters
            .where((p) => p.isRequiredPositional)
            .map(buildRequiredPositionalParam),
      );

      b.optionalParameters.addAll(
        m.parameters
            .where((p) => p.isOptionalPositional)
            .map(buildOptionalPositionalParam),
      );

      b.optionalParameters.addAll(
        m.parameters.where((p) => p.isNamed).map(buildNamedParam),
      );

      final List<Code> blocks = [
        url.assignFinal(_urlVar).statement,
      ];

      if (queries.isNotEmpty) {
        blocks.add(_generateMap(queries).assignFinal(_parametersVar).statement);
      }

      // Build an iterable of all the parameters that are nullable
      final Iterable<String> optionalNullableParameters = [
        ...m.parameters.where((p) => p.isOptionalPositional),
        ...m.parameters.where((p) => p.isNamed),
      ].where((el) => el.type.isNullable).map((el) => el.name);

      final bool hasQueryMap = queryMap.isNotEmpty;
      if (hasQueryMap) {
        if (queries.isNotEmpty) {
          blocks.add(refer('$_parametersVar.addAll').call(
            [
              // Check if the parameter is nullable
              optionalNullableParameters.contains(queryMap.keys.first)
                  ? refer(queryMap.keys.first).ifNullThen(refer('{}'))
                  : refer(queryMap.keys.first),
            ],
          ).statement);
        } else {
          blocks.add(
            // Check if the parameter is nullable
            optionalNullableParameters.contains(queryMap.keys.first)
                ? refer(queryMap.keys.first)
                    .ifNullThen(refer('{}'))
                    .assignFinal(_parametersVar)
                    .statement
                : refer(queryMap.keys.first)
                    .assignFinal(_parametersVar)
                    .statement,
          );
        }
      }

      final bool hasQuery = hasQueryMap || queries.isNotEmpty;

      if (headers != null) {
        blocks.add(headers);
      }

      final bool methodOptionalBody = getMethodOptionalBody(method);
      final String methodName = getMethodName(method);
      final String methodUrl = getMethodPath(method);
      bool hasBody = body.isNotEmpty || fields.isNotEmpty;
      if (hasBody) {
        if (body.isNotEmpty) {
          blocks.add(
            refer(body.keys.first).assignFinal(_bodyVar).statement,
          );
        } else {
          blocks.add(
            _generateMap(fields).assignFinal(_bodyVar).statement,
          );
        }
      }

      final bool hasFieldMap = fieldMap.isNotEmpty;
      if (hasFieldMap) {
        if (hasBody) {
          blocks.add(refer('$_bodyVar.addAll').call(
            [refer(fieldMap.keys.first)],
          ).statement);
        } else {
          blocks.add(
            refer(fieldMap.keys.first).assignFinal(_bodyVar).statement,
          );
        }
      }

      hasBody = hasBody || hasFieldMap;

      bool hasParts = multipart && (parts.isNotEmpty || fileFields.isNotEmpty);
      if (hasParts) {
        blocks.add(
          _generateList(parts, fileFields).assignFinal(_partsVar).statement,
        );
      }

      final bool hasPartMap = multipart && partMap.isNotEmpty;
      if (hasPartMap) {
        if (hasParts) {
          blocks.add(refer('$_partsVar.addAll').call(
            [refer(partMap.keys.first)],
          ).statement);
        } else {
          blocks.add(
            refer(partMap.keys.first).assignFinal(_partsVar).statement,
          );
        }
      }

      final bool hasFileFilesMap = multipart && fileFieldMap.isNotEmpty;
      if (hasFileFilesMap) {
        if (hasParts || hasPartMap) {
          blocks.add(refer('$_partsVar.addAll').call(
            [refer(fileFieldMap.keys.first)],
          ).statement);
        } else {
          blocks.add(
            refer(fileFieldMap.keys.first).assignFinal(_partsVar).statement,
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

      blocks.add(_generateRequest(
        method,
        hasBody: hasBody,
        useQueries: hasQuery,
        useHeaders: headers != null,
        hasParts: hasParts,
      ).assignFinal(_requestVar).statement);

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

      blocks.add(refer('$_clientVar.send')
          .call([refer(_requestVar)], namedArguments, typeArguments)
          .returned
          .statement);

      b.body = Block.of(blocks);
    });
  }

  /// TODO: upgrade analyzer to ^4.4.0 to replace enclosingElement with enclosingElement3
  /// https://github.com/dart-lang/sdk/blob/main/pkg/analyzer/CHANGELOG.md#440
  String _factoryForFunction(FunctionTypedElement function) =>
      // ignore: deprecated_member_use
      function.enclosingElement is ClassElement
          // ignore: deprecated_member_use
          ? '${function.enclosingElement!.name}.${function.name}'
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
    String path = getMethodPath(method);
    paths.forEach((p, ConstantReader r) {
      final String name = r.peek('name')?.stringValue ?? p.displayName;
      path = path.replaceFirst('{$name}', '\${${p.displayName}}');
    });

    if (path.startsWith('http://') || path.startsWith('https://')) {
      // if the request's url is already a fully qualified URL, we can use
      // as-is and ignore the baseUrl
      return literal(path);
    } else if (path.isEmpty && baseUrl.isEmpty) {
      return literal('');
    } else {
      if (path.isNotEmpty &&
          baseUrl.isNotEmpty &&
          !baseUrl.endsWith('/') &&
          !path.startsWith('/')) {
        return literal('$baseUrl/$path');
      }

      return literal('$baseUrl$path');
    }
  }

  Expression _generateRequest(
    ConstantReader method, {
    bool hasBody = false,
    bool hasParts = false,
    bool useQueries = false,
    bool useHeaders = false,
  }) {
    final List<Expression> params = [
      literal(getMethodName(method)),
      refer(_urlVar),
      refer('$_clientVar.$_baseUrlVar'),
    ];

    final Map<String, Expression> namedParams = {};

    if (hasBody) {
      namedParams['body'] = refer(_bodyVar);
    }

    if (hasParts) {
      namedParams['parts'] = refer(_partsVar);
      namedParams['multipart'] = literalBool(true);
    }

    if (useQueries) {
      namedParams['parameters'] = refer(_parametersVar);
    }

    if (useHeaders) {
      namedParams['headers'] = refer(_headersVar);
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
        'PartValue<${p.type.getDisplayString(withNullability: p.type.isNullable)}>',
      ).newInstance(params));
    });
    fileFields.forEach((p, ConstantReader r) {
      final String name = r.peek('name')?.stringValue ?? p.displayName;
      final List<Expression> params = [
        literal(name),
        refer(p.displayName),
      ];

      list.add(
        refer('PartValueFile<${p.type.getDisplayString(withNullability: p.type.isNullable)}>')
            .newInstance(params),
      );
    });

    return literalList(list, refer('PartValue'));
  }

  Code? _generateHeaders(MethodElement methodElement, ConstantReader method) {
    final StringBuffer codeBuffer = StringBuffer('')..writeln('{');

    // Search for @Header anotation in method parameters
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

    codeBuffer.writeln('};');
    final String code = codeBuffer.toString();

    return code == '{\n};\n' ? null : Code('final $_headersVar = $code');
  }
}

Builder chopperGeneratorFactoryBuilder({String? header}) => PartBuilder(
      [ChopperGenerator()],
      '.chopper.dart',
      header: header,
    );

bool getMethodOptionalBody(ConstantReader method) =>
    method.read('optionalBody').boolValue;

String getMethodPath(ConstantReader method) => method.read('path').stringValue;

String getMethodName(ConstantReader method) =>
    method.read('method').stringValue;

extension DartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
}

// All positional required params must support nullability
Parameter buildRequiredPositionalParam(ParameterElement p) => Parameter(
      (ParameterBuilder pb) => pb
        ..name = p.name
        ..type = Reference(
          p.type.getDisplayString(withNullability: p.type.isNullable),
        ),
    );

// All optional positional params must support nullability
Parameter buildOptionalPositionalParam(ParameterElement p) =>
    Parameter((ParameterBuilder pb) {
      pb
        ..name = p.name
        ..type = Reference(
          p.type.getDisplayString(withNullability: p.type.isNullable),
        );

      if (p.defaultValueCode != null) {
        pb.defaultTo = Code(p.defaultValueCode!);
      }
    });

// Named params can be optional or required, they also need to support
// nullability
Parameter buildNamedParam(ParameterElement p) =>
    Parameter((ParameterBuilder pb) {
      pb
        ..named = true
        ..name = p.name
        ..required = p.isRequiredNamed
        ..type = Reference(
          p.type.getDisplayString(withNullability: p.type.isNullable),
        );

      if (p.defaultValueCode != null) {
        pb.defaultTo = Code(p.defaultValueCode!);
      }
    });
