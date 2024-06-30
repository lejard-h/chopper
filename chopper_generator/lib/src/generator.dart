// ignore_for_file: deprecated_member_use

import 'dart:async' show FutureOr;

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

/// Code generator for [chopper.ChopperApi] annotated classes.
final class ChopperGenerator
    extends GeneratorForAnnotation<chopper.ChopperApi> {
  const ChopperGenerator();

  static final Logger _logger = Logger('Chopper Generator');

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
        todo:
            'Remove the [ChopperApi] annotation from `${element.displayName}`.',
      );
    }

    return _buildChopperApiImplementationClass(annotation, element);
  }

  static bool _extendsChopperService(InterfaceType type) =>
      _typeChecker(chopper.ChopperService).isExactlyType(type);

  static Field _buildDefinitionTypeMethod(String superType) => Field(
        (method) => method
          ..annotations.add(refer('override'))
          ..type = refer('Type')
          ..name = 'definitionType'
          ..modifier = FieldModifier.final$
          ..assignment = Code(superType),
      );

  static String _buildChopperApiImplementationClass(
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

    final ConstantReader? baseUrlReader =
        annotation.peek(Vars.baseUrl.toString());

    TopLevelVariableElement? baseUrlVariableElement;

    final VariableElement? possibleBaseUrl =
        baseUrlReader?.objectValue.variable;

    if (possibleBaseUrl is TopLevelVariableElement &&
        possibleBaseUrl.type.isDartCoreString &&
        possibleBaseUrl.isConst) {
      baseUrlVariableElement = possibleBaseUrl;
    }

    final String baseUrl = baseUrlReader?.stringValue ?? '';

    final Class classBuilder = Class((builder) {
      builder
        ..modifier = ClassModifier.final$
        ..name = name
        ..extend = refer(friendlyName)
        ..fields.add(_buildDefinitionTypeMethod(friendlyName))
        ..constructors.add(_generateConstructor())
        ..methods.addAll(_parseMethods(
          element,
          baseUrl,
          baseUrlVariableElement,
        ));
    });

    const String ignore = '// coverage:ignore-file\n'
        '// ignore_for_file: type=lint';
    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);

    return DartFormatter().format('$ignore\n${classBuilder.accept(emitter)}');
  }

  static Constructor _generateConstructor() => Constructor(
        (ConstructorBuilder constructorBuilder) => constructorBuilder
          ..optionalParameters.add(
            Parameter(
              (paramBuilder) => paramBuilder
                ..name = Vars.client.toString()
                ..type = TypeReference(
                  (typeBuilder) => typeBuilder
                    ..symbol = '${chopper.ChopperClient}'
                    ..isNullable = true,
                ),
            ),
          )
          ..body = Code(
            [
              'if (${Vars.client} == null) return;',
              'this.${Vars.client} = ${Vars.client};'
            ].join('\n'),
          ),
      );

  static Iterable<Method> _parseMethods(
    ClassElement element,
    String baseUrl,
    TopLevelVariableElement? baseUrlVariableElement,
  ) =>
      element.methods
          .where(
            (MethodElement method) =>
                _getMethodAnnotation(method) != null &&
                method.isAbstract &&
                method.returnType.isDartAsyncFuture,
          )
          .map(
            (MethodElement m) => _generateMethod(
              m,
              baseUrl,
              baseUrlVariableElement,
            ),
          );

  static Method _generateMethod(
    MethodElement m,
    String baseUrl,
    TopLevelVariableElement? baseUrlVariableElement,
  ) {
    final ConstantReader? method = _getMethodAnnotation(m);
    final bool multipart = _hasAnnotation(m, chopper.Multipart);
    final bool formUrlEncoded = _hasAnnotation(m, chopper.FormUrlEncoded);
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
    final Map<String, ConstantReader> tag = _getAnnotation(m, chopper.Tag);

    final Code? headers = _generateHeaders(m, method!, formUrlEncoded);
    final Expression url = _generateUrl(
      method,
      paths,
      baseUrl,
      baseUrlVariableElement,
    );

    // Check if Response is present in the return type
    final bool isResponseObject = _isResponse(m.returnType);
    final DartType? responseType =
        _getResponseType(m.returnType, isResponseObject);
    final DartType? responseInnerType =
        _getResponseInnerType(m.returnType) ?? responseType;

    // Set Response with generic types
    final Reference responseTypeReference = refer(
        responseType?.getDisplayString(withNullability: false) ??
            responseType?.getDisplayString(withNullability: false) ??
            'dynamic');
    // Set the return type
    final returnType = isResponseObject
        ? refer(m.returnType.getDisplayString(withNullability: false))
        : TypeReference(
            (b) => b
              ..symbol = 'Future'
              ..types.add(responseTypeReference),
          );

    return Method((MethodBuilder methodBuilder) {
      methodBuilder
        ..annotations.add(refer('override'))
        ..name = m.displayName
        // We don't support returning null Type
        ..returns = returnType
        // And null Typed parameters
        ..types.addAll(
          m.typeParameters.map(
            (t) => refer(t.getDisplayString(withNullability: false)),
          ),
        )
        ..requiredParameters.addAll(
          m.parameters
              .where((p) => p.isRequiredPositional)
              .map(Utils.buildRequiredPositionalParam),
        )
        ..optionalParameters.addAll(
          m.parameters
              .where((p) => p.isOptionalPositional)
              .map(Utils.buildOptionalPositionalParam),
        )
        ..optionalParameters.addAll(
          m.parameters.where((p) => p.isNamed).map(Utils.buildNamedParam),
        );

      // Make method async if Response is omitted.
      // We need the await the response in order to return the body.
      if (!isResponseObject) {
        methodBuilder.modifier = MethodModifier.async;
      }

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
          blocks.add(
            refer(Vars.parameters.toString()).property('addAll').call(
              [
                /// Check if the parameter is nullable
                if (optionalNullableParameters.contains(queryMap.keys.first))
                  refer(queryMap.keys.first).ifNullThen(literalConstMap({}))
                else
                  refer(queryMap.keys.first),
              ],
            ).statement,
          );
        } else {
          blocks.add(
            declareFinal(
              Vars.parameters.toString(),
              type: refer('Map<String, dynamic>'),
            )
                .assign(
                  /// Check if the parameter is nullable
                  optionalNullableParameters.contains(queryMap.keys.first)
                      ? refer(queryMap.keys.first)
                          .ifNullThen(literalConstMap({}))
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
          final DartType bodyType = m.parameters
              .firstWhere((p) => _typeChecker(chopper.Body).hasAnnotationOf(p))
              .type;
          final Expression map = (formUrlEncoded &&
                  _isMap(bodyType) &&
                  !_isMapStringString(bodyType))
              ? _generateMapToStringExpression(refer(body.keys.first))
              : refer(body.keys.first);
          blocks.add(
            declareFinal(Vars.body.toString()).assign(map).statement,
          );
        } else {
          blocks.add(
            declareFinal(Vars.body.toString())
                .assign(_generateMap(fields, enableToString: formUrlEncoded))
                .statement,
          );
        }
      }

      final bool hasFieldMap = fieldMap.isNotEmpty;
      if (hasFieldMap) {
        final DartType fieldMapType = m.parameters
            .firstWhere(
                (p) => _typeChecker(chopper.FieldMap).hasAnnotationOf(p))
            .type;
        final Expression map =
            (formUrlEncoded && !_isMapStringString(fieldMapType))
                ? _generateMapToStringExpression(refer(fieldMap.keys.first))
                : refer(fieldMap.keys.first);
        if (hasBody) {
          blocks.add(
            refer(Vars.body.toString()).property('addAll').call(
              [map],
            ).statement,
          );
        } else {
          blocks.add(
            declareFinal(Vars.body.toString()).assign(map).statement,
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
            refer(Vars.parts.toString()).property('addAll').call(
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
            refer(Vars.parts.toString()).property('addAll').call(
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

      final bool hasTag = tag.isNotEmpty;

      final chopper.ListFormat? listFormat = Utils.getListFormat(method);

      final bool? useBrackets = Utils.getUseBrackets(method);

      final bool? includeNullQueryVars = Utils.getIncludeNullQueryVars(method);

      final Duration? timeout = Utils.getTimeout(method);

      blocks.add(
        declareFinal(Vars.request.toString(), type: refer('Request'))
            .assign(
              _generateRequest(
                method,
                hasBody: hasBody,
                useQueries: hasQuery,
                useHeaders: headers != null,
                hasParts: hasParts,
                tagRefer: hasTag ? refer(tag.keys.first) : null,
                listFormat: listFormat,
                // ignore: deprecated_member_use_from_same_package
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
        typeArguments.addAll([
          refer(responseType.getDisplayString(withNullability: false)),
          refer(responseInnerType!.getDisplayString(withNullability: false)),
        ]);
      }

      Expression returnStatement =
          refer(Vars.client.toString()).property('send').call(
        [refer(Vars.request.toString())],
        namedArguments,
        typeArguments,
      );
      if (timeout != null) {
        returnStatement = returnStatement.property('timeout').call([
          refer('Duration').constInstance([], {
            'microseconds': literalNum(timeout.inMicroseconds),
          }),
        ]);
      }

      if (isResponseObject) {
        // Return the response object directly from chopper.send
        blocks.add(returnStatement.returned.statement);
      } else {
        // Await the response object from chopper.send
        blocks.add(
          // generic types are not passed in the code_builder at the moment.
          declareFinal(
            Vars.response.toString(),
            type: TypeReference(
              (b) => b
                ..symbol = 'Response'
                ..types.add(responseTypeReference),
            ),
          ).assign(returnStatement.awaited).statement,
        );
        // Return the body of the response object
        blocks.add(refer(Vars.response.toString())
            .property('bodyOrThrow')
            .returned
            .statement);
      }

      methodBuilder.body = Block.of(blocks);
    });
  }

  static Expression _generateMapToStringExpression(Reference map) {
    return map.property('map<String, String>').call([
      Method((b) => b
        ..requiredParameters.add(
          Parameter((b) => b..name = 'key'),
        )
        ..requiredParameters.add(
          Parameter((b) => b..name = 'value'),
        )
        ..returns = refer('MapEntry', 'dart.core')
        ..body = refer('MapEntry', 'dart.core')
            .newInstance([
              refer('key').property('toString').call([]),
              refer('value').property('toString').call([]),
            ])
            .returned
            .statement).closure
    ]);
  }

  static String _factoryForFunction(FunctionTypedElement function) =>
      function.enclosingElement is ClassElement
          ? '${function.enclosingElement!.name}.${function.name}'
          : function.name!;

  static Map<String, ConstantReader> _getAnnotation(
    MethodElement method,
    Type type,
  ) {
    DartObject? annotation;
    String name = '';

    for (final ParameterElement p in method.parameters) {
      final DartObject? a = _typeChecker(type).firstAnnotationOf(p);
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

  static Map<ParameterElement, ConstantReader> _getAnnotations(
    MethodElement m,
    Type type,
  ) =>
      {
        for (final ParameterElement p in m.parameters)
          if (_typeChecker(type).hasAnnotationOf(p))
            p: ConstantReader(_typeChecker(type).firstAnnotationOf(p)),
      };

  static TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  static ConstantReader? _getMethodAnnotation(MethodElement method) {
    for (final Type type in _methodsAnnotations) {
      final DartObject? annotation = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annotation != null) {
        return ConstantReader(annotation);
      }
    }

    return null;
  }

  static ConstantReader? _getFactoryConverterAnnotation(MethodElement method) {
    final DartObject? annotation = _typeChecker(chopper.FactoryConverter)
        .firstAnnotationOf(method, throwOnUnresolved: false);

    return annotation != null ? ConstantReader(annotation) : null;
  }

  static bool _hasAnnotation(MethodElement method, Type type) =>
      _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false) !=
      null;

  static const List<Type> _methodsAnnotations = [
    chopper.Get,
    chopper.Post,
    chopper.Delete,
    chopper.Put,
    chopper.Patch,
    chopper.Method,
    chopper.Head,
    chopper.Options,
  ];

  static DartType? _genericOf(DartType? type) =>
      type is InterfaceType && type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  static bool _isMap(DartType type) {
    return _typeChecker(Map).isExactlyType(type) ||
        _typeChecker(Map).isAssignableFromType(type);
  }

  static bool _isMapStringString(DartType type) {
    if (!_isMap(type)) {
      return false;
    }
    final firsType = type is InterfaceType && type.typeArguments.isNotEmpty
        ? type.typeArguments.first
        : null;
    final secondType = type is InterfaceType && type.typeArguments.length > 1
        ? type.typeArguments[1]
        : null;
    if (firsType == null || secondType == null) {
      return false;
    }
    return _isString(firsType) && _isString(secondType);
  }

  static bool _isString(DartType type) {
    return _typeChecker(String).isExactlyType(type) ||
        _typeChecker(String).isAssignableFromType(type);
  }

  static bool _isResponse(DartType type) {
    final DartType? responseType = _genericOf(type);
    if (responseType == null) return false;

    return _typeChecker(chopper.Response).isExactlyType(responseType);
  }

  static DartType? _getResponseType(DartType type, bool isResponseObject) =>
      isResponseObject ? _genericOf(_genericOf(type)) : _genericOf(type);

  static DartType? _getResponseInnerType(DartType type) {
    final DartType? generic = _genericOf(type);

    if (generic == null ||
        _typeChecker(Map).isExactlyType(type) ||
        _typeChecker(BuiltMap).isExactlyType(type)) return type;

    if (generic.isDynamic) return null;

    if (_typeChecker(List).isExactlyType(type) ||
        _typeChecker(BuiltList).isExactlyType(type)) return generic;

    return _getResponseInnerType(generic);
  }

  static Expression _generateUrl(
    ConstantReader method,
    Map<ParameterElement, ConstantReader> paths,
    String baseUrl,
    TopLevelVariableElement? baseUrlVariableElement,
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
    }

    if (path.isEmpty && baseUrl.isEmpty) {
      return _generateUri('');
    }

    String finalBaseUrl = baseUrl;

    if (baseUrlVariableElement != null) {
      finalBaseUrl = '\${${baseUrlVariableElement.displayName}}';
    }

    if (path.isNotEmpty && baseUrl.isNotEmpty) {
      bool pathHasSlash = path.startsWith('/');
      bool baseUrlHasSlash = baseUrl.endsWith('/');

      if ((!baseUrlHasSlash && !pathHasSlash)) {
        return _generateUri('$finalBaseUrl/$path');
      }

      if (baseUrlHasSlash && pathHasSlash) {
        return _generateUri('$finalBaseUrl${path.replaceFirst('/', '')}');
      }
    }

    if (finalBaseUrl.startsWith('http://') ||
        finalBaseUrl.startsWith('https://')) {
      final tempUri = Uri.tryParse(finalBaseUrl);

      if (tempUri != null) {
        final urlNoScheme =
            '${tempUri.authority}${tempUri.path}$path'.replaceAll('//', '/');
        return _generateUri(
          '${tempUri.scheme}://$urlNoScheme',
        );
      }
    }

    return _generateUri(
      '$finalBaseUrl$path'.replaceAll('//', '/'),
    );
  }

  static Expression _generateUri(String url) =>
      refer('Uri').newInstanceNamed('parse', [literal(url)]);

  static Expression _generateRequest(
    ConstantReader method, {
    bool hasBody = false,
    bool hasParts = false,
    bool useQueries = false,
    bool useHeaders = false,
    chopper.ListFormat? listFormat,
    @Deprecated('Use listFormat instead') bool? useBrackets,
    bool? includeNullQueryVars,
    Reference? tagRefer,
  }) =>
      refer('Request').newInstance(
        [
          literal(Utils.getMethodName(method)),
          refer(Vars.url.toString()),
          refer(Vars.client.toString()).property(Vars.baseUrl.toString()),
        ],
        {
          if (hasBody) 'body': refer(Vars.body.toString()),
          if (hasParts) ...{
            'parts': refer(Vars.parts.toString()),
            'multipart': literalBool(true),
          },
          if (useQueries) 'parameters': refer(Vars.parameters.toString()),
          if (useHeaders) 'headers': refer(Vars.headers.toString()),
          if (tagRefer != null) 'tag': tagRefer,
          if (listFormat != null)
            'listFormat': refer('ListFormat').type.property(listFormat.name),
          if (useBrackets != null) 'useBrackets': literalBool(useBrackets),
          if (includeNullQueryVars != null)
            'includeNullQueryVars': literalBool(includeNullQueryVars),
        },
      );

  static Expression _generateMap(
    Map<ParameterElement, ConstantReader> queries, {
    bool enableToString = false,
  }) =>
      literalMap(
        {
          for (final MapEntry<ParameterElement, ConstantReader> query
              in queries.entries)
            query.value.peek('name')?.stringValue ?? query.key.displayName:
                enableToString
                    ? refer(query.key.displayName).property('toString').call([])
                    : refer(query.key.displayName),
        },
        refer('String'),
        refer(enableToString ? 'String' : 'dynamic'),
      );

  static Expression _generateList(
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

  static Code? _generateHeaders(
    MethodElement methodElement,
    ConstantReader method,
    bool formUrlEncoded,
  ) {
    final StringBuffer codeBuffer = StringBuffer('')..writeln('{');

    /// Search for @Header annotation in method parameters
    final Map<ParameterElement, ConstantReader> annotations =
        _getAnnotations(methodElement, chopper.Header);

    annotations.forEach((
      ParameterElement parameter,
      ConstantReader annotation,
    ) {
      final String paramName = parameter.displayName;
      final String name = annotation.peek('name')?.stringValue ?? paramName;
      final String headerValue = switch (parameter.type.isDartCoreString) {
        true => "'$name': $paramName,",
        false => "'$name': $paramName.toString(),",
      };
      if (parameter.type.isNullable) {
        codeBuffer.writeln('if ($paramName != null) $headerValue');
      } else {
        codeBuffer.writeln(headerValue);
      }
    });

    final ConstantReader? headersReader = method.peek('headers');
    if (headersReader == null) return null;

    final Map<DartObject?, DartObject?> methodAnnotations =
        headersReader.mapValue;

    methodAnnotations.forEach((headerName, headerValue) {
      if (headerName != null && headerValue != null) {
        codeBuffer.writeln(
          "'${headerName.toStringValue()}': ${literal(headerValue.toStringValue())},",
        );
      }
    });

    if (formUrlEncoded) {
      codeBuffer
          .writeln("'content-type': 'application/x-www-form-urlencoded',");
    }

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
