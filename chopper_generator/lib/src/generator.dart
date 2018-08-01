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
const _parametersVar = "params";
const _headersVar = "headers";
const _requestVar = "request";

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
          todo:
              'Remove the ServiceDefinition annotation from `$friendlyName`.');
    }

    return _buildImplementionClass(annotation, element);
  }

  String _buildImplementionClass(
    ConstantReader annotation,
    ClassElement element,
  ) {
    final friendlyName = element.name;
    final builderName =
        annotation?.peek("name")?.stringValue ?? "${friendlyName}Impl";

    final classBuilder = new Class((c) {
      return c
        ..name = builderName
        ..extend = new Reference("${chopper.ChopperService}")
        ..methods.addAll(element.methods.where((MethodElement m) {
          final methodAnnot = _getMethodAnnotation(m);
          return methodAnnot != null &&
              m.isAbstract &&
              m.returnType.isDartAsyncFuture;
        }).map((MethodElement m) {
          final method = _getMethodAnnotation(m);
          final body = _getAnnotation(m, chopper.Body);
          final paths = _getAnnotations(m, chopper.Path);
          final queries = _getAnnotations(m, chopper.Query);
          final headers = _generateHeaders(m, method);
          final url = _generateUrl(method, paths);
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
              blocks.add(_genereteQueryParams(queries));
            }

            if (headers != null) {
              blocks.add(headers);
            }

            blocks.add(_generateRequest(method, body,
                    useQueries: queries.isNotEmpty, useHeaders: headers != null)
                .assignFinal(_requestVar)
                .statement);

            final namedArguments = <String, Expression>{};
            final typeArguments = <Reference>[];
            if (responseType != null) {
              namedArguments["responseType"] =
                  refer(responseType.displayName).expression;
              typeArguments.add(refer(responseType.displayName));
            }

            blocks.add(refer("client.send")
                .call([refer(_requestVar)], namedArguments, typeArguments)
                .returned
                .statement);

            b.body = new Block.of(blocks);

            return b;
          });
        }))
        ..implements.add(new Reference(friendlyName));
    });

    final emitter = new DartEmitter();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
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

  Map<String, ConstantReader> _getAnnotations(MethodElement m, Type type) {
    var annot = <String, ConstantReader>{};
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annot[p.displayName] = new ConstantReader(a);
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
      ConstantReader method, Map<String, ConstantReader> paths) {
    String value = "${method.read("url").stringValue}";
    paths.forEach((String key, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? key;
      value = value.replaceFirst("{$name}", "\$$key");
    });
    return literal('$value');
  }

  Expression _generateRequest(
      ConstantReader method, Map<String, ConstantReader> body,
      {bool useQueries: false, bool useHeaders: false}) {
    final params = <Expression>[
      literal(method.peek("method").stringValue),
      refer(_urlVar)
    ];

    final namedParams = <String, Expression>{};

    if (body.isNotEmpty) {
      namedParams["body"] = refer(body.keys.first);
    }

    if (useQueries) {
      namedParams["parameters"] = refer(_parametersVar);
    }

    if (useHeaders) {
      namedParams["headers"] = refer(_headersVar);
    }

    return refer("Request").newInstance(params, namedParams);
  }

  Code _genereteQueryParams(Map<String, ConstantReader> queries) {
    final map = {};
    queries.forEach((String key, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? key;
      map[literal(name)] = refer(key);
    });

    return literalMap(map).assignFinal(_parametersVar).statement;
  }

  Code _generateHeaders(MethodElement m, ConstantReader method) {
    final map = {};

    final annotations = _getAnnotations(m, chopper.Header);

    annotations.forEach((String key, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? key;
      map[literal(name)] = refer(key);
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
      header: header,
      generatedExtension: ".chopper.dart",
    );
