///@nodoc
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';

import 'package:source_gen/source_gen.dart';
// TODO(lejard_h) Code builder not null safe yet
// ignore: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:logging/logging.dart';

const _clientVar = 'client';
const _baseUrlVar = 'baseUrl';
const _parametersVar = '\$params';
const _headersVar = '\$headers';
const _requestVar = '\$request';
const _bodyVar = '\$body';
const _partsVar = '\$parts';
const _urlVar = '\$url';

final _logger = Logger('Chopper Generator');

class ChopperGenerator extends GeneratorForAnnotation<chopper.ChopperApi> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
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
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: '`$friendlyName` need to extends the [ChopperService] class.',
      );
    }

    final friendlyName = element.name;
    final name = '_\$$friendlyName';
    final baseUrl = annotation.peek(_baseUrlVar)?.stringValue ?? '';

    final classBuilder = Class((builder) {
      builder
        ..name = name
        ..extend = refer(friendlyName)
        ..fields.add(_buildDefinitionTypeMethod(friendlyName))
        ..constructors.add(_generateConstructor())
        ..methods.addAll(_parseMethods(element, baseUrl));
    });

    final ignore =
        '// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations';
    final emitter = DartEmitter();
    return DartFormatter().format('$ignore\n${classBuilder.accept(emitter)}');
  }

  Constructor _generateConstructor() => Constructor((constructorBuilder) {
        constructorBuilder.optionalParameters.add(
          Parameter((paramBuilder) {
            paramBuilder.name = _clientVar;
            paramBuilder.type = refer('${chopper.ChopperClient}?');
          }),
        );

        constructorBuilder.body = Code(
          'if ($_clientVar == null) return;\nthis.$_clientVar = $_clientVar;',
        );
      });

  Iterable<Method> _parseMethods(ClassElement element, String baseUrl) {
    return element.methods.where((MethodElement method) {
      final methodAnnotation = _getMethodAnnotation(method);
      return methodAnnotation != null &&
          method.isAbstract &&
          method.returnType.isDartAsyncFuture;
    }).map((MethodElement m) => _generateMethod(m, baseUrl));
  }

  Method _generateMethod(MethodElement m, String baseUrl) {
    final method = _getMethodAnnotation(m);
    final multipart = _hasAnnotation(m, chopper.Multipart);
    final factoryConverter = _getFactoryConverterAnnotation(m);

    final body = _getAnnotation(m, chopper.Body);
    final paths = _getAnnotations(m, chopper.Path);
    final queries = _getAnnotations(m, chopper.Query);
    final queryMap = _getAnnotation(m, chopper.QueryMap);
    final fields = _getAnnotations(m, chopper.Field);
    final parts = _getAnnotations(m, chopper.Part);
    final fileFields = _getAnnotations(m, chopper.PartFile);

    final headers = _generateHeaders(m, method!);
    final url = _generateUrl(method, paths, baseUrl);
    final responseType = _getResponseType(m.returnType);
    final responseInnerType =
        _getResponseInnerType(m.returnType) ?? responseType;

    return Method((b) {
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

      final blocks = [
        url.assignFinal(_urlVar).statement,
      ];

      if (queries.isNotEmpty) {
        blocks.add(_generateMap(queries).assignFinal(_parametersVar).statement);
      }

      final hasQueryMap = queryMap.isNotEmpty;
      if (hasQueryMap) {
        if (queries.isNotEmpty) {
          blocks.add(refer('$_parametersVar.addAll').call(
            [refer(queryMap.keys.first)],
          ).statement);
        } else {
          blocks.add(
            refer(queryMap.keys.first).assignFinal(_parametersVar).statement,
          );
        }
      }

      final hasQuery = hasQueryMap || queries.isNotEmpty;

      if (headers != null) {
        blocks.add(headers);
      }

      final methodOptionalBody = getMethodOptionalBody(method);
      final methodName = getMethodName(method);
      final methodUrl = getMethodPath(method);
      final hasBody = body.isNotEmpty || fields.isNotEmpty;
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

      final hasParts =
          multipart == true && (parts.isNotEmpty || fileFields.isNotEmpty);
      if (hasParts) {
        blocks.add(
            _generateList(parts, fileFields).assignFinal(_partsVar).statement);
      }

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

      final namedArguments = <String, Expression>{};

      final requestFactory = factoryConverter?.peek('request');
      if (requestFactory != null) {
        final func = requestFactory.objectValue.toFunctionValue();
        namedArguments['requestConverter'] = refer(_factoryForFunction(func!));
      }

      final responseFactory = factoryConverter?.peek('response');
      if (responseFactory != null) {
        final func = responseFactory.objectValue.toFunctionValue();
        namedArguments['responseConverter'] = refer(_factoryForFunction(func!));
      }

      final typeArguments = <Reference>[];
      if (responseType != null) {
        typeArguments
            .add(refer(responseType.getDisplayString(withNullability: false)));
        typeArguments.add(
            refer(responseInnerType!.getDisplayString(withNullability: false)));
      }

      blocks.add(refer('$_clientVar.send')
          .call([refer(_requestVar)], namedArguments, typeArguments)
          .returned
          .statement);

      b.body = Block.of(blocks);
    });
  }

  String _factoryForFunction(FunctionTypedElement function) {
    if (function.enclosingElement is ClassElement) {
      return '${function.enclosingElement!.name}.${function.name}';
    }
    return function.name!;
  }

  Map<String, ConstantReader> _getAnnotation(MethodElement method, Type type) {
    var annotation;
    var name = '';
    for (final p in method.parameters) {
      dynamic a = _typeChecker(type).firstAnnotationOf(p);
      if (annotation != null && a != null) {
        throw Exception(
            'Too many $type annotation for \'${method.displayName}\'');
      } else if (annotation == null && a != null) {
        annotation = a;
        name = p.displayName;
      }
    }
    if (annotation == null) return {};
    return {name: ConstantReader(annotation)};
  }

  Map<ParameterElement, ConstantReader> _getAnnotations(
      MethodElement m, Type type) {
    var annotation = <ParameterElement, ConstantReader>{};
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annotation[p] = ConstantReader(a);
      }
    }
    return annotation;
  }

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  ConstantReader? _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annotation = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annotation != null) return ConstantReader(annotation);
    }
    return null;
  }

  ConstantReader? _getFactoryConverterAnnotation(MethodElement method) {
    final annotation = _typeChecker(chopper.FactoryConverter)
        .firstAnnotationOf(method, throwOnUnresolved: false);
    if (annotation != null) return ConstantReader(annotation);
    return null;
  }

  bool _hasAnnotation(MethodElement method, Type type) {
    final annotation =
        _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false);

    return annotation != null;
  }

  final _methodsAnnotations = const [
    chopper.Get,
    chopper.Post,
    chopper.Delete,
    chopper.Put,
    chopper.Patch,
    chopper.Method,
    chopper.Head,
    chopper.Options,
  ];

  DartType? _genericOf(DartType? type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty
        ? type.typeArguments.first
        : null;
  }

  DartType? _getResponseType(DartType type) {
    return _genericOf(_genericOf(type));
  }

  DartType? _getResponseInnerType(DartType type) {
    final generic = _genericOf(type);

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
    var path = getMethodPath(method);
    paths.forEach((p, ConstantReader r) {
      final name = r.peek('name')?.stringValue ?? p.displayName;
      path = path.replaceFirst('{$name}', '\$${p.displayName}');
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
    final params = <Expression>[
      literal(getMethodName(method)),
      refer(_urlVar),
      refer('$_clientVar.$_baseUrlVar'),
    ];

    final namedParams = <String, Expression>{};

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
    final map = {};
    queries.forEach((p, ConstantReader r) {
      final name = r.peek('name')?.stringValue ?? p.displayName;
      map[literal(name)] = refer(p.displayName);
    });

    return literalMap(map, refer('String'), refer('dynamic'));
  }

  Expression _generateList(
    Map<ParameterElement, ConstantReader> parts,
    Map<ParameterElement, ConstantReader> fileFields,
  ) {
    final list = [];
    parts.forEach((p, ConstantReader r) {
      final name = r.peek('name')?.stringValue ?? p.displayName;
      final params = <Expression>[
        literal(name),
        refer(p.displayName),
      ];

      list.add(refer(
              'PartValue<${p.type.getDisplayString(withNullability: p.type.isNullable)}>')
          .newInstance(params));
    });
    fileFields.forEach((p, ConstantReader r) {
      final name = r.peek('name')?.stringValue ?? p.displayName;
      final params = <Expression>[
        literal(name),
        refer(p.displayName),
      ];

      list.add(
        refer('PartValueFile<${p.type.getDisplayString(withNullability: false)}>')
            .newInstance(params),
      );
    });
    return literalList(list, refer('PartValue'));
  }

  Code? _generateHeaders(MethodElement methodElement, ConstantReader method) {
    final codeBuffer = StringBuffer('')..writeln('{');

    // Search for @Header anotation in method parameters
    final annotations = _getAnnotations(methodElement, chopper.Header);

    annotations.forEach((parameter, ConstantReader annotation) {
      final paramName = parameter.displayName;
      final name = annotation.peek('name')?.stringValue ?? paramName;

      if (parameter.type.isNullable) {
        codeBuffer.writeln('if ($paramName != null) \'$name\': $paramName,');
      } else {
        codeBuffer.writeln('\'$name\': $paramName,');
      }
    });

    final headersReader = method.peek('headers');
    if (headersReader == null) return null;

    final methodAnnotations = headersReader.mapValue;

    methodAnnotations.forEach((headerName, headerValue) {
      if (headerName != null && headerValue != null) {
        codeBuffer.writeln(
          '\'${headerName.toStringValue()}\': ${literal(headerValue.toStringValue())},',
        );
      }
    });

    codeBuffer.writeln('};');
    final code = codeBuffer.toString();
    if (code == '{\n};\n') {
      return null;
    }

    return Code('final $_headersVar = $code');
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
Parameter buildRequiredPositionalParam(ParameterElement p) {
  return Parameter(
    (pb) => pb
      ..name = p.name
      ..type = Reference(
        p.type.getDisplayString(withNullability: p.type.isNullable),
      ),
  );
}

// All optional positional params must support nullability
Parameter buildOptionalPositionalParam(ParameterElement p) {
  return Parameter((pb) {
    pb
      ..name = p.name
      ..type = Reference(
        p.type.getDisplayString(withNullability: p.type.isNullable),
      );

    if (p.defaultValueCode != null) {
      pb.defaultTo = Code(p.defaultValueCode!);
    }
  });
}

// Named params can be optional or required, they also need to support
// nullability
Parameter buildNamedParam(ParameterElement p) {
  return Parameter((pb) {
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
}
