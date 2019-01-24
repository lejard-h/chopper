///@nodoc
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dart_style/dart_style.dart';

import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'package:chopper/chopper.dart' as chopper;

const _urlVar = "url";
const _baseUrlVar = "baseUrl";
const _parametersVar = "params";
const _headersVar = "headers";
const _requestVar = "request";
const _bodyVar = 'body';
const _partsVar = 'parts';
const _clientVar = 'client';

class ChopperGenerator extends GeneratorForAnnotation<chopper.ChopperApi> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [ChopperApi] annotation from `$friendlyName`.',
      );
    }

    return _buildImplementionClass(annotation, element);
  }

  bool _extendsChopperService(InterfaceType t) =>
      _typeChecker(chopper.ChopperService).isExactlyType(t);

  Field _buildDefinitionTypeMethod(String superType) => Field(
        (m) => m
          ..name = 'definitionType'
          ..modifier = FieldModifier.final$
          ..assignment = Code(superType),
      );

  String _buildImplementionClass(
    ConstantReader annotation,
    ClassElement element,
  ) {
    if (element.allSupertypes.any(_extendsChopperService) == false) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: '`$friendlyName` need to extends the [ChopperService] class.',
      );
    }

    final friendlyName = element.name;
    final name = '_\$${friendlyName}';
    final baseUrl = annotation?.peek(_baseUrlVar)?.stringValue ?? '';

    final classBuilder = new Class((c) {
      c
        ..name = name
        ..constructors.addAll([
          _generateConstructor(),
        ])
        ..methods.addAll(_parseMethods(element, baseUrl))
        ..fields.add(_buildDefinitionTypeMethod(friendlyName))
        ..extend = refer(friendlyName);
    });

    final emitter = new DartEmitter();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  Constructor _generateConstructor() => Constructor((c) {
        c.optionalParameters.add(Parameter((p) {
          p.name = _clientVar;
          p.type = refer('${chopper.ChopperClient}');
        }));

        c.body = Code(
          'if ($_clientVar == null) return;this.$_clientVar = $_clientVar;',
        );
      });

  Iterable<Method> _parseMethods(ClassElement element, String baseUrl) =>
      element.methods.where((MethodElement m) {
        final methodAnnot = _getMethodAnnotation(m);
        return methodAnnot != null &&
            m.isAbstract &&
            m.returnType.isDartAsyncFuture;
      }).map((MethodElement m) => _generateMethod(m, baseUrl));

  Method _generateMethod(MethodElement m, String baseUrl) {
    final method = _getMethodAnnotation(m);
    final multipart = _hasAnnotation(m, chopper.Multipart);
    final formUrlEncoded = _hasAnnotation(m, chopper.FormUrlEncoded);
    final hasJson = _hasAnnotation(m, chopper.JsonEncoded);

    final body = _getAnnotation(m, chopper.Body);
    final paths = _getAnnotations(m, chopper.Path);
    final queries = _getAnnotations(m, chopper.Query);
    final fields = _getAnnotations(m, chopper.Field);
    final parts = _getAnnotations(m, chopper.Part);
    final fileFields = _getAnnotations(m, chopper.FileField);

    final headers = _generateHeaders(m, method);
    final url = _generateUrl(method, paths, baseUrl);
    final responseType = _getResponseType(m.returnType);

    return new Method((b) {
      b.name = m.displayName;
      b.returns = new Reference(m.returnType.displayName);
      b.requiredParameters.addAll(m.parameters
          .where((p) => p.isNotOptional)
          .map((p) => new Parameter((pb) => pb
            ..name = p.name
            ..type = new Reference(p.type.displayName))));

      b.optionalParameters.addAll(m.parameters
          .where((p) => p.isOptionalPositional)
          .map((p) => new Parameter((pb) => pb
            ..name = p.name
            ..type = new Reference(p.type.displayName))));

      b.optionalParameters.addAll(m.parameters
          .where((p) => p.isNamed)
          .map((p) => new Parameter((pb) => pb
            ..named = true
            ..name = p.name
            ..type = new Reference(p.type.displayName))));

      final blocks = [
        url.assignFinal(_urlVar).statement,
      ];

      if (queries.isNotEmpty) {
        blocks.add(_genereteMap(queries).assignFinal(_parametersVar).statement);
      }

      if (headers != null) {
        blocks.add(headers);
      }

      final hasBody =
          body.isNotEmpty || (formUrlEncoded == true && fields.isNotEmpty);
      if (hasBody) {
        if (body.isNotEmpty) {
          blocks.add(
            refer(body.keys.first).assignFinal(_bodyVar).statement,
          );
        } else {
          blocks.add(
            _genereteMap(fields).assignFinal(_bodyVar).statement,
          );
        }
      }

      final hasParts =
          multipart == true && (parts.isNotEmpty || fileFields.isNotEmpty);
      if (hasParts) {
        blocks.add(
            _genereteList(parts, fileFields).assignFinal(_partsVar).statement);
      }

      blocks.add(_generateRequest(
        method,
        hasBody: hasBody,
        useQueries: queries.isNotEmpty,
        useHeaders: headers != null,
        hasParts: hasParts,
        hasFormUrlEncoded: formUrlEncoded,
        hasJson: hasJson,
      ).assignFinal(_requestVar).statement);

      final namedArguments = <String, Expression>{};
      final typeArguments = <Reference>[];
      if (responseType != null) {
        typeArguments.add(refer(responseType.displayName));
      }

      blocks.add(refer("client.send")
          .call([refer(_requestVar)], namedArguments, typeArguments)
          .returned
          .statement);

      b.body = new Block.of(blocks);
    });
  }

  Map<String, ConstantReader> _getAnnotation(MethodElement m, Type type) {
    var annot;
    String name;
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (annot != null && a != null) {
        throw new Exception("Too many $type annotation for '${m.displayName}");
      } else if (annot == null && a != null) {
        annot = a;
        name = p.displayName;
      }
    }
    if (annot == null) return {};
    return {name: new ConstantReader(annot)};
  }

  Map<ParameterElement, ConstantReader> _getAnnotations(
      MethodElement m, Type type) {
    var annot = <ParameterElement, ConstantReader>{};
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annot[p] = new ConstantReader(a);
      }
    }
    return annot;
  }

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);

  ConstantReader _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annot != null) return new ConstantReader(annot);
    }
    return null;
  }

  bool _hasAnnotation(MethodElement method, Type type) {
    final annot =
        _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false);

    return annot != null;
  }

  final _methodsAnnotations = const [
    chopper.Get,
    chopper.Post,
    chopper.Delete,
    chopper.Put,
    chopper.Patch,
    chopper.Method
  ];

  DartType _genericOf(DartType type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty
        ? type.typeArguments.first
        : null;
  }

  DartType _getResponseType(DartType type) {
    final generic = _genericOf(type);
    if (generic == null ||
        _typeChecker(Map).isExactlyType(type) ||
        _typeChecker(List).isExactlyType(type)) {
      return type;
    }
    if (generic.isDynamic) {
      return null;
    }
    return _getResponseType(generic);
  }

  Expression _generateUrl(
    ConstantReader method,
    Map<ParameterElement, ConstantReader> paths,
    String baseUrl,
  ) {
    String value = "${method.read("url").stringValue}";
    paths.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      value = value.replaceFirst("{$name}", "\$${p.displayName}");
    });
    if (!baseUrl.endsWith('/') && !value.startsWith('/')) {
      return literal('$baseUrl/$value');
    }

    return literal('$baseUrl$value');
  }

  Expression _generateRequest(
    ConstantReader method, {
    bool hasBody: false,
    bool hasParts: false,
    bool useQueries: false,
    bool useHeaders: false,
    bool hasFormUrlEncoded: false,
    bool hasJson: false,
  }) {
    final params = <Expression>[
      literal(method.peek("method").stringValue),
      refer(_urlVar),
      refer('$_clientVar.$_baseUrlVar'),
    ];

    final namedParams = <String, Expression>{};

    if (hasBody) {
      namedParams[_bodyVar] = refer(_bodyVar);
    }

    if (hasParts) {
      namedParams[_partsVar] = refer(_partsVar);
      namedParams['multipart'] = literalBool(true);
    }

    if (hasJson) {
      namedParams['json'] = literalBool(true);
    } else if (hasFormUrlEncoded) {
      namedParams['json'] = literalBool(false);
    } else {
      namedParams['json'] = refer('$_clientVar.jsonApi');
    }

    if (useQueries) {
      namedParams["parameters"] = refer(_parametersVar);
    }

    if (useHeaders) {
      namedParams["headers"] = refer(_headersVar);
    }

    return refer("Request").newInstance(params, namedParams);
  }

  Expression _genereteMap(Map<ParameterElement, ConstantReader> queries) {
    final map = {};
    queries.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      map[literal(name)] = refer(p.displayName);
    });

    return literalMap(map);
  }

  Expression _genereteList(
    Map<ParameterElement, ConstantReader> parts,
    Map<ParameterElement, ConstantReader> fileFields,
  ) {
    final list = [];
    parts.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      final params = <Expression>[
        literal(name),
        refer(p.displayName),
      ];

      list.add(refer('PartValue<${p.type.displayName}>').newInstance(params));
    });
    fileFields.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      final params = <Expression>[
        literal(name),
        refer(p.displayName),
      ];

      list.add(refer('PartFile<${p.type.displayName}>').newInstance(params));
    });
    return literalList(list);
  }

  Code _generateHeaders(MethodElement m, ConstantReader method) {
    final map = {};

    final annotations = _getAnnotations(m, chopper.Header);

    annotations.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      map[literal(name)] = refer(p.displayName);
    });

    final methodAnnotations = method.peek("headers").mapValue;

    methodAnnotations.forEach((k, v) {
      map[literal(k.toStringValue())] = literal(v.toStringValue());
    });

    if (map.isEmpty) {
      return null;
    }

    return literalMap(map).assignFinal(_headersVar).statement;
  }
}

Builder chopperGeneratorFactoryBuilder({String header}) => new PartBuilder(
      [new ChopperGenerator()],
      ".chopper.dart",
      header: header,
    );
