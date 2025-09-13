// ignore_for_file: deprecated_member_use

import 'dart:async' show FutureOr;

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:chopper_generator/src/extensions.dart';
import 'package:chopper_generator/src/utils.dart';
import 'package:chopper_generator/src/vars.dart';
import 'package:code_builder/code_builder.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

/// Code generator for [chopper.ChopperApi] annotated classes.
///
/// Responsibilities
/// * Validate that the annotated element is a [ClassElement2] that extends
///   [chopper.ChopperService].
/// * Synthesize implementations for abstract API methods, wiring up
///   paths, queries, headers, body/parts, and calling [chopper.ChopperClient.send].
/// * Prefer pattern matching over force-unwraps to keep null-safety explicit.
///
/// Throws
/// * [InvalidGenerationSourceError] if misapplied or required metadata is missing.
final class ChopperGenerator
    extends GeneratorForAnnotation<chopper.ChopperApi> {
  const ChopperGenerator();

  static final Logger _logger = Logger('Chopper Generator');

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`.',
        todo:
            'Remove the [ChopperApi] annotation from `${element.displayName}`.',
      );
    }

    return _buildChopperApiImplementationClass(annotation, element);
  }

  /// Returns true iff the given type is exactly [chopper.ChopperService].
  static bool _extendsChopperService(InterfaceType type) => _typeChecker(
    chopper.ChopperService,
    inPackage: 'chopper',
  ).isExactlyType(type);

  /// Builds the `definitionType` override used by Chopper to infer the
  /// original abstract service type at runtime.
  static Field _buildDefinitionTypeMethod(String superType) => Field(
    (FieldBuilder method) =>
        method
          ..annotations.add(refer('override'))
          ..type = refer('Type')
          ..name = 'definitionType'
          ..modifier = FieldModifier.final$
          ..assignment = Code(superType),
  );

  /// Emits the concrete implementation class for a given `@ChopperApi` service.
  /// Returns the formatted Dart source as a string.
  static String _buildChopperApiImplementationClass(
    ConstantReader annotation,
    ClassElement2 element,
  ) {
    // Ensure the annotated class derives from `ChopperService`.
    if (!element.allSupertypes.any(_extendsChopperService)) {
      final String friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: '`$friendlyName` need to extends the [ChopperService] class.',
      );
    }

    final String friendlyName = switch (element.name3) {
      final String name? => name,
      null =>
        throw InvalidGenerationSourceError(
          'Generator cannot target a class without a name.',
        ),
    };
    final String name = '_\$$friendlyName';

    final ConstantReader? baseUrlReader = annotation.peek(
      Vars.baseUrl.toString(),
    );

    TopLevelVariableElement2? baseUrlVariableElement;

    final VariableElement2? possibleBaseUrl =
        baseUrlReader?.objectValue.variable2;

    if (possibleBaseUrl is TopLevelVariableElement2 &&
        possibleBaseUrl.type.isDartCoreString &&
        possibleBaseUrl.isConst) {
      baseUrlVariableElement = possibleBaseUrl;
    }

    final String baseUrl = baseUrlReader?.stringValue ?? '';

    final Class classBuilder = Class(
      (ClassBuilder b) =>
          b
            ..modifier = ClassModifier.final$
            ..name = name
            ..extend = refer(friendlyName)
            ..fields.add(_buildDefinitionTypeMethod(friendlyName))
            ..constructors.add(_generateConstructor())
            ..methods.addAll(
              _parseMethods(element, baseUrl, baseUrlVariableElement),
            ),
    );

    const String ignore =
        '// coverage:ignore-file\n'
        '// ignore_for_file: type=lint';
    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);

    return '$ignore\n${classBuilder.accept(emitter)}';
  }

  /// Generates a constructor that optionally accepts a [chopper.ChopperClient] and
  /// assigns it to `this.client` if provided.
  static Constructor _generateConstructor() => Constructor(
    (ConstructorBuilder b) =>
        b
          ..optionalParameters.add(
            Parameter(
              (ParameterBuilder p) =>
                  p
                    ..name = Vars.client.toString()
                    ..type = TypeReference(
                      (TypeReferenceBuilder t) =>
                          t
                            ..symbol = '${chopper.ChopperClient}'
                            ..isNullable = true,
                    ),
            ),
          )
          ..body = Code(
            [
              'if (${Vars.client} == null) return;',
              'this.${Vars.client} = ${Vars.client};',
            ].join('\n'),
          ),
  );

  /// Filters abstract methods that look like Chopper endpoints and maps them
  /// to their generated implementations.
  static Iterable<Method> _parseMethods(
    ClassElement2 element,
    String baseUrl,
    TopLevelVariableElement2? baseUrlVariableElement,
  ) => element.methods2
      .where(
        (method) =>
            _getMethodAnnotation(method) != null &&
            method.isAbstract &&
            method.returnType.isDartAsyncFuture,
      )
      .map((m) => _generateMethod(m, baseUrl, baseUrlVariableElement));

  /// Generates a concrete implementation for a single abstract API method.
  /// Handles:
  /// * HTTP method detection and headers
  /// * Path, query, field, and part parameter mapping
  /// * Optional body/parts, multipart, and factory converters
  /// * Return type plumbing (`Future<Response<T>>` vs `Future<T>`).
  static Method _generateMethod(
    MethodElement2 m,
    String baseUrl,
    TopLevelVariableElement2? baseUrlVariableElement,
  ) {
    // Extract and validate the HTTP method annotation (@Get/@Post/@Put/@Patch/@Delete/...).
    final ConstantReader method = switch (_getMethodAnnotation(m)) {
      final ConstantReader reader? => reader,
      null =>
        throw InvalidGenerationSourceError(
          'Missing HTTP method annotation on "${m.displayName}".',
          element: m.baseElement,
        ),
    };
    // Per-method configuration flags
    final bool multipart = _hasAnnotation(m, chopper.Multipart);
    final bool formUrlEncoded = _hasAnnotation(m, chopper.FormUrlEncoded);
    final ConstantReader? factoryConverter = _getFactoryConverterAnnotation(m);

    final Map<String, ConstantReader> body = _getAnnotation(m, chopper.Body);
    final Map<FormalParameterElement, ConstantReader> paths = _getAnnotations(
      m,
      chopper.Path,
    );
    final Map<FormalParameterElement, ConstantReader> queries = _getAnnotations(
      m,
      chopper.Query,
    );
    final Map<String, ConstantReader> queryMap = _getAnnotation(
      m,
      chopper.QueryMap,
    );
    final Map<FormalParameterElement, ConstantReader> fields = _getAnnotations(
      m,
      chopper.Field,
    );
    final Map<String, ConstantReader> fieldMap = _getAnnotation(
      m,
      chopper.FieldMap,
    );
    final Map<FormalParameterElement, ConstantReader> parts = _getAnnotations(
      m,
      chopper.Part,
    );
    final Map<String, ConstantReader> partMap = _getAnnotation(
      m,
      chopper.PartMap,
    );
    final Map<FormalParameterElement, ConstantReader> fileFields =
        _getAnnotations(m, chopper.PartFile);
    final Map<String, ConstantReader> fileFieldMap = _getAnnotation(
      m,
      chopper.PartFileMap,
    );
    final Map<String, ConstantReader> tag = _getAnnotation(m, chopper.Tag);

    // Pre-build static and parameter-driven headers (or null if none)
    final Code? headers = _generateHeaders(m, method, formUrlEncoded);
    final Expression url = _generateUrl(
      method,
      paths,
      baseUrl,
      baseUrlVariableElement,
    );

    // Return type analysis: does the method return `Future<Response<T>>`?
    final bool isResponseObject = _isResponse(m.returnType);
    final DartType? responseType = _getResponseType(
      m.returnType,
      isResponseObject,
    );
    final DartType? responseInnerType =
        _getResponseInnerType(m.returnType) ?? responseType;

    // Set Response with generic types
    final Reference responseTypeReference = refer(
      responseType?.getDisplayString(withNullability: false) ?? 'dynamic',
    );
    // Set the return type
    final Reference returnType =
        isResponseObject
            ? refer(m.returnType.getDisplayString(withNullability: false))
            : TypeReference(
              (TypeReferenceBuilder b) =>
                  b
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
          m.typeParameters2.map(
            (TypeParameterElement2 t) => refer(switch (t.bound) {
              final DartType type? => type.getDisplayString(
                withNullability: false,
              ),
              null =>
                throw InvalidGenerationSourceError(
                  'Type parameter without a bound on method "${m.displayName}".',
                  element: m.baseElement,
                ),
            }),
          ),
        )
        ..requiredParameters.addAll(
          m.formalParameters
              .where((p) => p.isRequiredPositional)
              .map(Utils.buildRequiredPositionalParam),
        )
        ..optionalParameters.addAll(
          m.formalParameters
              .where((p) => p.isOptionalPositional)
              .map(Utils.buildOptionalPositionalParam),
        )
        ..optionalParameters.addAll(
          m.formalParameters.where((p) => p.isNamed).map(Utils.buildNamedParam),
        );

      // Detect optional @AbortTrigger parameter (passed by the caller)
      final abortParam = Utils.findAbortTriggerParam(m);
      final String? abortParamName = abortParam?.displayName;

      // Make method async if Response is omitted.
      // We need the await the response in order to return the body.
      if (!isResponseObject) {
        methodBuilder.modifier = MethodModifier.async;
      }

      final List<Code> blocks = [
        declareFinal(
          Vars.url.toString(),
          type: refer('Uri'),
        ).assign(url).statement,
      ];

      if (queries.isNotEmpty) {
        blocks.add(
          declareFinal(
            Vars.parameters.toString(),
            type: refer('Map<String, dynamic>'),
          ).assign(_generateMap(queries)).statement,
        );
      }

      /// Build an iterable of all parameters that are nullable so we can handle
      /// `QueryMap`/`FieldMap` nullability without using `!`.
      final Iterable<String> optionalNullableParameters = [
            ...m.formalParameters.where((p) => p.isOptionalPositional),
            ...m.formalParameters.where((p) => p.isNamed),
          ]
          .where((FormalParameterElement el) => el.type.isNullable)
          .map(
            (FormalParameterElement el) => switch (el.name3) {
              final String name? => name,
              null =>
                throw InvalidGenerationSourceError(
                  'Encountered a parameter without a name.',
                  element: el.baseElement,
                ),
            },
          );

      final bool hasQueryMap = queryMap.isNotEmpty;
      if (hasQueryMap) {
        if (queries.isNotEmpty) {
          blocks.add(
            refer(Vars.parameters.toString()).property('addAll').call([
              /// Check if the parameter is nullable
              if (optionalNullableParameters.contains(queryMap.keys.first))
                refer(queryMap.keys.first).ifNullThen(literalConstMap(const {}))
              else
                refer(queryMap.keys.first),
            ]).statement,
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
                      ? refer(
                        queryMap.keys.first,
                      ).ifNullThen(literalConstMap(const {}))
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
          final DartType bodyType =
              m.formalParameters
                  .firstWhere(
                    (FormalParameterElement p) => _typeChecker(
                      chopper.Body,
                      inPackage: 'chopper',
                    ).hasAnnotationOf(p),
                  )
                  .type;
          final Expression map =
              (formUrlEncoded &&
                      _isMap(bodyType) &&
                      !_isMapStringString(bodyType))
                  ? _generateMapToStringExpression(refer(body.keys.first))
                  : refer(body.keys.first);
          blocks.add(declareFinal(Vars.body.toString()).assign(map).statement);
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
        final DartType fieldMapType =
            m.formalParameters
                .firstWhere(
                  (FormalParameterElement p) => _typeChecker(
                    chopper.FieldMap,
                    inPackage: 'chopper',
                  ).hasAnnotationOf(p),
                )
                .type;
        final Expression map =
            (formUrlEncoded && !_isMapStringString(fieldMapType))
                ? _generateMapToStringExpression(refer(fieldMap.keys.first))
                : refer(fieldMap.keys.first);
        if (hasBody) {
          blocks.add(
            refer(
              Vars.body.toString(),
            ).property('addAll').call([map]).statement,
          );
        } else {
          blocks.add(declareFinal(Vars.body.toString()).assign(map).statement);
        }
      }

      hasBody = hasBody || hasFieldMap;

      bool hasParts = multipart && (parts.isNotEmpty || fileFields.isNotEmpty);
      if (hasParts) {
        blocks.add(
          declareFinal(
            Vars.parts.toString(),
            type: refer('List<PartValue>'),
          ).assign(_generateList(parts, fileFields)).statement,
        );
      }

      final bool hasPartMap = multipart && partMap.isNotEmpty;
      if (hasPartMap) {
        if (hasParts) {
          blocks.add(
            refer(
              Vars.parts.toString(),
            ).property('addAll').call([refer(partMap.keys.first)]).statement,
          );
        } else {
          blocks.add(
            declareFinal(
              Vars.parts.toString(),
              type: refer('List<PartValue>'),
            ).assign(refer(partMap.keys.first)).statement,
          );
        }
      }

      final bool hasFileFilesMap = multipart && fileFieldMap.isNotEmpty;
      if (hasFileFilesMap) {
        if (hasParts || hasPartMap) {
          blocks.add(
            refer(Vars.parts.toString()).property('addAll').call([
              refer(fileFieldMap.keys.first),
            ]).statement,
          );
        } else {
          blocks.add(
            declareFinal(
              Vars.parts.toString(),
              type: refer('List<PartValue>'),
            ).assign(refer(fileFieldMap.keys.first)).statement,
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
          '   e.g.: @POST(optionalBody: true)',
        );
      }

      final bool hasTag = tag.isNotEmpty;

      final chopper.ListFormat? listFormat = Utils.getListFormat(method);

      final chopper.DateFormat? dateFormat = Utils.getDateFormat(method);

      final bool? useBrackets = Utils.getUseBrackets(method);

      final bool? includeNullQueryVars = Utils.getIncludeNullQueryVars(method);

      final Duration? timeout = Utils.getTimeout(method);

      // Disallow defining both a timeout and an @AbortTrigger on the same method
      if (timeout != null && abortParamName != null) {
        throw InvalidGenerationSourceError(
          'Method "${m.displayName}" cannot define both a timeout and an @AbortTrigger parameter. Choose one.',
          element: m.baseElement,
          todo:
              'Remove either the timeout from the annotation or the @AbortTrigger parameter.',
        );
      }

      // Timeout & abort behavior
      // If a timeout is configured, create an auto-abort that fires at the deadline.
      Expression? abortTriggerExpr;
      if (timeout != null) {
        blocks.add(
          declareFinal(
                Vars.abortTrigger.toString(),
                type: TypeReference(
                  (TypeReferenceBuilder t) =>
                      t
                        ..symbol = 'ChopperCompleter'
                        ..url = 'package:chopper/chopper.dart'
                        ..types.add(refer('void')),
                ),
              )
              .assign(
                TypeReference(
                  (TypeReferenceBuilder t) =>
                      t
                        ..symbol = 'ChopperCompleter'
                        ..url = 'package:chopper/chopper.dart'
                        ..types.add(refer('void')),
                ).newInstance(const []),
              )
              .statement,
        );

        // $timeout: triggers auto-abort after `timeout`
        final Expression durationExpr = refer('Duration').constInstance(
          const [],
          {'microseconds': literalNum(timeout.inMicroseconds)},
        );

        blocks.add(
          declareFinal(
                Vars.timeout.toString(),
                type: TypeReference(
                  (TypeReferenceBuilder t) =>
                      t
                        ..symbol = 'ChopperTimer'
                        ..url = 'package:chopper/chopper.dart',
                ),
              )
              .assign(
                refer(
                  'ChopperTimer',
                  'package:chopper/chopper.dart',
                ).newInstance([
                  durationExpr,
                  Method(
                    (MethodBuilder b) =>
                        b
                          ..body = Code(
                            'if (!${Vars.abortTrigger}.isCompleted) ${Vars.abortTrigger}.complete();',
                          ),
                  ).closure,
                ]),
              )
              .statement,
        );

        // Use the auto-abort future directly
        abortTriggerExpr = refer(
          Vars.abortTrigger.toString(),
        ).property('future');
      } else if (abortParamName != null) {
        // No timeout: pass through the caller-provided abort future if present
        abortTriggerExpr = refer(abortParamName);
      }

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
                dateFormat: dateFormat,
                includeNullQueryVars: includeNullQueryVars,
                abortTriggerExpr: abortTriggerExpr,
              ),
            )
            .statement,
      );

      final Map<String, Expression> namedArguments = {};

      final ConstantReader? requestFactory = factoryConverter?.peek('request');
      if (requestFactory != null) {
        if (requestFactory.objectValue.toFunctionValue2()
            case final ExecutableElement2 func?) {
          namedArguments['requestConverter'] = refer(_factoryForFunction(func));
        }
      }

      final ConstantReader? responseFactory = factoryConverter?.peek(
        'response',
      );
      if (responseFactory != null) {
        if (responseFactory.objectValue.toFunctionValue2()
            case final ExecutableElement func?) {
          namedArguments['responseConverter'] = refer(
            _factoryForFunction(func),
          );
        }
      }

      final List<Reference> typeArguments = [
        if (responseType != null) ...[
          refer(responseType.getDisplayString(withNullability: false)),
          refer(
            (responseInnerType ?? responseType).getDisplayString(
              withNullability: false,
            ),
          ),
        ],
      ];

      /// Generates a user-friendly timeout message based on the given duration.
      String getTimeoutExceptionMessage(Duration timeout) => switch (timeout) {
        > const Duration(days: 1) =>
          'Request timed out after ${timeout.inDays} days',
        == const Duration(days: 1) =>
          'Request timed out after ${timeout.inDays} day',
        > const Duration(hours: 1) =>
          'Request timed out after ${timeout.inHours} hours',
        == const Duration(hours: 1) =>
          'Request timed out after ${timeout.inHours} hour',
        > const Duration(minutes: 1) =>
          'Request timed out after ${timeout.inMinutes} minutes',
        == const Duration(minutes: 1) =>
          'Request timed out after ${timeout.inMinutes} minute',
        > const Duration(seconds: 1) =>
          'Request timed out after ${timeout.inSeconds} seconds',
        == const Duration(seconds: 1) =>
          'Request timed out after ${timeout.inSeconds} second',
        > const Duration(milliseconds: 1) =>
          'Request timed out after ${timeout.inMilliseconds} milliseconds',
        == const Duration(milliseconds: 1) =>
          'Request timed out after ${timeout.inMilliseconds} millisecond',
        > const Duration(microseconds: 1) =>
          'Request timed out after ${timeout.inMicroseconds} microseconds',
        == const Duration(microseconds: 1) =>
          'Request timed out after ${timeout.inMicroseconds} microsecond',
        >= Duration.zero || _ => 'Request timed out',
      };

      Expression returnStatement = refer(Vars.client.toString())
          .property('send')
          .call(
            [refer(Vars.request.toString())],
            namedArguments,
            typeArguments,
          );

      if (timeout != null) {
        if (isResponseObject) {
          returnStatement = returnStatement
              .property('catchError')
              .call(
                [
                  // onError
                  Method(
                    (MethodBuilder b) =>
                        b
                          ..requiredParameters.add(
                            Parameter((ParameterBuilder p) => p..name = '_'),
                          )
                          ..lambda = true
                          ..body = Block.of([
                            TypeReference(
                              (TypeReferenceBuilder t) =>
                                  t
                                    ..symbol = 'Future'
                                    ..url = 'dart:async'
                                    ..types.add(
                                      TypeReference(
                                        (TypeReferenceBuilder t2) =>
                                            t2
                                              ..symbol = 'Response'
                                              ..url =
                                                  'package:chopper/chopper.dart'
                                              ..types.add(
                                                responseTypeReference,
                                              ),
                                      ),
                                    ),
                            ).property('error').call([
                              refer('ChopperTimeoutException').newInstance([
                                literal(getTimeoutExceptionMessage(timeout)),
                              ]),
                            ]).code,
                          ]),
                  ).closure,
                ],
                {
                  'test':
                      Method(
                        (MethodBuilder b) =>
                            b
                              ..requiredParameters.add(
                                Parameter(
                                  (ParameterBuilder p) =>
                                      p
                                        ..name = 'err'
                                        ..type = refer('Object'),
                                ),
                              )
                              ..lambda = true
                              ..body =
                                  refer('err')
                                      .isA(
                                        refer(
                                          'ChopperRequestAbortedException',
                                          'package:chopper/chopper.dart',
                                        ),
                                      )
                                      .and(
                                        refer(
                                          Vars.abortTrigger.toString(),
                                        ).property('isCompleted'),
                                      )
                                      .code,
                      ).closure,
                },
              )
              .property('whenComplete')
              .call([refer(Vars.timeout.toString()).property('cancel')]);
        }
      }

      if (isResponseObject) {
        // Return the response object directly from chopper.send
        blocks.add(returnStatement.returned.statement);
      } else {
        if (timeout != null) {
          // Build a chain: send().then((resp) => resp.bodyOrThrow)
          final Expression mapToBody =
              Method(
                (MethodBuilder b) =>
                    b
                      ..requiredParameters.add(
                        Parameter(
                          (ParameterBuilder p) =>
                              p
                                ..name = 'resp'
                                ..type = TypeReference(
                                  (TypeReferenceBuilder t) =>
                                      t
                                        ..symbol = 'Response'
                                        ..url = 'package:chopper/chopper.dart'
                                        ..types.add(responseTypeReference),
                                ),
                        ),
                      )
                      ..lambda = true
                      ..body = refer('resp').property('bodyOrThrow').code,
              ).closure;

          final Expression chained = returnStatement
              .property('then')
              .call([mapToBody], const {}, [responseTypeReference])
              // Map auto-abort to TimeoutException and always cancel the timer
              .property('catchError')
              .call(
                [
                  Method(
                    (MethodBuilder b) =>
                        b
                          ..requiredParameters.add(
                            Parameter((ParameterBuilder p) => p..name = '_'),
                          )
                          ..lambda = true
                          ..body = Block.of([
                            TypeReference(
                              (TypeReferenceBuilder t) =>
                                  t
                                    ..symbol = 'Future'
                                    ..url = 'dart:async'
                                    ..types.add(responseTypeReference),
                            ).property('error').call([
                              refer(
                                'ChopperTimeoutException',
                                'package:chopper/chopper.dart',
                              ).newInstance([
                                literal(getTimeoutExceptionMessage(timeout)),
                              ]),
                            ]).code,
                          ]),
                  ).closure,
                ],
                {
                  'test':
                      Method(
                        (MethodBuilder b) =>
                            b
                              ..requiredParameters.add(
                                Parameter(
                                  (ParameterBuilder p) =>
                                      p
                                        ..name = 'err'
                                        ..type = refer('Object'),
                                ),
                              )
                              ..lambda = true
                              ..body =
                                  refer('err')
                                      .isA(
                                        refer(
                                          'ChopperRequestAbortedException',
                                          'package:chopper/chopper.dart',
                                        ),
                                      )
                                      .and(
                                        refer(
                                          Vars.abortTrigger.toString(),
                                        ).property('isCompleted'),
                                      )
                                      .code,
                      ).closure,
                },
              )
              .property('whenComplete')
              .call([refer(Vars.timeout.toString()).property('cancel')]);

          blocks.add(chained.returned.statement);
        } else {
          // Await the response object from chopper.send
          blocks.add(
            declareFinal(
              Vars.response.toString(),
              type: TypeReference(
                (TypeReferenceBuilder b) =>
                    b
                      ..symbol = 'Response'
                      ..url = 'package:chopper/chopper.dart'
                      ..types.add(responseTypeReference),
              ),
            ).assign(returnStatement.awaited).statement,
          );
          // Return the body of the response object
          blocks.add(
            refer(
              Vars.response.toString(),
            ).property('bodyOrThrow').returned.statement,
          );
        }
      }

      methodBuilder.body = Block.of(blocks);
    });
  }

  /// Converts a `Map` with non-string keys/values to `Map<String, String>` by
  /// calling `toString()` on both key and value; used for form-url-encoded bodies.
  static Expression _generateMapToStringExpression(Reference map) {
    return map.property('map<String, String>').call([
      Method(
        (MethodBuilder b) =>
            b
              ..requiredParameters.add(
                Parameter((ParameterBuilder b) => b..name = 'key'),
              )
              ..requiredParameters.add(
                Parameter((ParameterBuilder b) => b..name = 'value'),
              )
              ..returns = refer('MapEntry', 'dart.core')
              ..body =
                  refer('MapEntry', 'dart.core')
                      .newInstance([
                        refer('key').property('toString').call([]),
                        refer('value').property('toString').call([]),
                      ])
                      .returned
                      .statement,
      ).closure,
    ]);
  }

  /// Formats a reference to a top-level or static factory function, including
  /// its enclosing class name if present.
  static String _factoryForFunction(FunctionTypedElement2 function) {
    final String fnName = switch (function.name3) {
      final String name? => name,
      null =>
        throw InvalidGenerationSourceError(
          'Unable to resolve factory function name.',
        ),
    };

    if (function.enclosingElement2 is ClassElement2) {
      final ClassElement2 cls = function.enclosingElement2 as ClassElement2;
      final String clsName = switch (cls.name3) {
        final String n? => n,
        null =>
          throw InvalidGenerationSourceError(
            'Unable to resolve enclosing class name for factory function.',
          ),
      };
      return '$clsName.$fnName';
    }

    return fnName;
  }

  /// Returns a single-parameter annotation map for the specified type.
  /// If multiple parameters have the same annotation, throws.
  static Map<String, ConstantReader> _getAnnotation(
    MethodElement2 method,
    Type type,
  ) {
    DartObject? annotation;
    String name = '';

    for (final FormalParameterElement p in method.formalParameters) {
      // Skip parameters marked as @AbortTrigger from all other annotation buckets
      if (Utils.isAbortTriggerParam(p)) continue;
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

    return {if (annotation != null) name: ConstantReader(annotation)};
  }

  /// Returns a map of parameters to their annotation metadata for the given type.
  static Map<FormalParameterElement, ConstantReader> _getAnnotations(
    MethodElement2 m,
    Type type,
  ) => {
    for (final FormalParameterElement p in m.formalParameters)
      // Skip parameters marked as @AbortTrigger from all other annotation buckets
      if (!Utils.isAbortTriggerParam(p) &&
          _typeChecker(type).hasAnnotationOf(p))
        p: ConstantReader(_typeChecker(type).firstAnnotationOf(p)),
  };

  /// Small helper to get a [TypeChecker] for a runtime type.
  static TypeChecker _typeChecker(
    Type type, {
    String? inPackage,
    bool? inSdk,
  }) => TypeChecker.typeNamed(type, inPackage: inPackage, inSdk: inSdk);

  /// Scans supported HTTP method annotations (@Get/@Post/...) and returns the first match.
  static ConstantReader? _getMethodAnnotation(MethodElement2 method) {
    for (final Type type in _methodsAnnotations) {
      final DartObject? annotation = _typeChecker(
        type,
      ).firstAnnotationOf(method, throwOnUnresolved: false);
      if (annotation != null) {
        return ConstantReader(annotation);
      }
    }

    return null;
  }

  /// Returns the `@FactoryConverter` annotation if present on the method.
  static ConstantReader? _getFactoryConverterAnnotation(MethodElement2 method) {
    final DartObject? annotation = _typeChecker(
      chopper.FactoryConverter,
      inPackage: 'chopper',
    ).firstAnnotationOf(method, throwOnUnresolved: false);

    return annotation != null ? ConstantReader(annotation) : null;
  }

  /// Checks whether the given method has an annotation of the given type.
  static bool _hasAnnotation(MethodElement2 method, Type type) =>
      _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false) !=
      null;

  /// Supported HTTP method annotations in priority order.
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

  /// Returns the first type argument if `type` is a generic interface; otherwise null.
  static DartType? _genericOf(DartType? type) =>
      type is InterfaceType && type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  /// True if the type is (or is assignable to) [Map].
  static bool _isMap(DartType type) =>
      type.isDartCoreMap ||
      _typeChecker(Map, inSdk: true).isAssignableFromType(type);

  /// True if the type is a `Map<String, String>`.
  static bool _isMapStringString(DartType type) =>
      _isMap(type) &&
      switch (type) {
        InterfaceType(
          typeArguments: [final DartType k, final DartType v, ...],
        ) =>
          _isString(k) && _isString(v),
        _ => false,
      };

  /// True if the type is (or is assignable to) [String].
  static bool _isString(DartType type) =>
      type.isDartCoreString ||
      (type is InterfaceType &&
          type.element3.name3 == 'String' &&
          type.element3.library2.uri.toString() == 'dart:core');

  /// True if the outer generic of `type` is [chopper.Response].
  static bool _isResponse(DartType type) => switch (_genericOf(type)) {
    InterfaceType(
      element3: InterfaceElement(
        name3: 'Response',
        library2: final LibraryElement lib,
      ),
    ) =>
      lib.uri.toString().startsWith('package:chopper/'),
    _ => false,
  };

  /// For `Future<Response<T>>`, returns `T`. For `Future<T>`, returns `T`.
  static DartType? _getResponseType(DartType type, bool isResponseObject) =>
      isResponseObject ? _genericOf(_genericOf(type)) : _genericOf(type);

  /// Recursively unwraps nested generics to return the innermost element type.
  static DartType? _getResponseInnerType(DartType type) {
    final DartType? generic = _genericOf(type);

    if (generic == null ||
        type.isDartCoreMap ||
        _typeChecker(
          BuiltMap,
          inPackage: 'built_collection',
        ).isExactlyType(type)) {
      return type;
    }

    if (generic is DynamicType) return null;

    if (type.isDartCoreList ||
        _typeChecker(
          BuiltList,
          inPackage: 'built_collection',
        ).isExactlyType(type)) {
      return generic;
    }

    return _getResponseInnerType(generic);
  }

  /// Builds the final [Uri] used for the request, combining [baseUrl] and path,
  /// and substituting any `@Path` parameters.
  static Expression _generateUrl(
    ConstantReader method,
    Map<FormalParameterElement, ConstantReader> paths,
    String baseUrl,
    TopLevelVariableElement2? baseUrlVariableElement,
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
        final urlNoScheme = '${tempUri.authority}${tempUri.path}$path'
            .replaceAll('//', '/');
        return _generateUri('${tempUri.scheme}://$urlNoScheme');
      }
    }

    return _generateUri('$finalBaseUrl$path'.replaceAll('//', '/'));
  }

  /// Helper to create `Uri.parse(url)` as a code expression.
  static Expression _generateUri(String url) =>
      refer('Uri').newInstanceNamed('parse', [literal(url)]);

  /// Creates the [chopper.Request] expression with all optional named arguments
  /// (body, parts, parameters, headers, tag, listFormat, etc.).
  static Expression _generateRequest(
    ConstantReader method, {
    bool hasBody = false,
    bool hasParts = false,
    bool useQueries = false,
    bool useHeaders = false,
    chopper.ListFormat? listFormat,
    @Deprecated('Use listFormat instead') bool? useBrackets,
    chopper.DateFormat? dateFormat,
    bool? includeNullQueryVars,
    Expression? abortTriggerExpr,
    Reference? tagRefer,
  }) => refer('Request').newInstance(
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
      if (dateFormat != null)
        'dateFormat': refer('DateFormat').type.property(dateFormat.name),
      if (includeNullQueryVars != null)
        'includeNullQueryVars': literalBool(includeNullQueryVars),
      if (abortTriggerExpr != null) 'abortTrigger': abortTriggerExpr,
    },
  );

  /// Builds a literal `Map<String, dynamic>` for query/field parameters.
  static Expression _generateMap(
    Map<FormalParameterElement, ConstantReader> queries, {
    bool enableToString = false,
  }) => literalMap(
    {
      for (final MapEntry<FormalParameterElement, ConstantReader> query
          in queries.entries)
        query.value.peek('name')?.stringValue ?? query.key.displayName:
            enableToString
                ? refer(
                  query.key.displayName,
                ).property('toString').call(const [])
                : refer(query.key.displayName),
    },
    refer('String'),
    refer(enableToString ? 'String' : 'dynamic'),
  );

  /// Builds a `List<PartValue>` (and [chopper.PartValueFile]) for multipart requests.
  static Expression _generateList(
    Map<FormalParameterElement, ConstantReader> parts,
    Map<FormalParameterElement, ConstantReader> fileFields,
  ) {
    final List list = [];

    parts.forEach(
      (FormalParameterElement p, ConstantReader r) => list.add(
        refer(
          'PartValue<${p.type.getDisplayString(withNullability: p.type.isNullable)}>',
        ).newInstance([
          literal(r.peek('name')?.stringValue ?? p.displayName),
          refer(p.displayName),
        ]),
      ),
    );

    fileFields.forEach(
      (FormalParameterElement p, ConstantReader r) => list.add(
        refer(
          'PartValueFile<${p.type.getDisplayString(withNullability: p.type.isNullable)}>',
        ).newInstance([
          literal(r.peek('name')?.stringValue ?? p.displayName),
          refer(p.displayName),
        ]),
      ),
    );

    return literalList(list, refer('PartValue'));
  }

  /// Emits a `Map<String, String>` for headers, merging parameter-level
  /// `@Header()`s with the static `headers:` map on the HTTP annotation.
  /// Returns `null` if no headers are present.
  static Code? _generateHeaders(
    MethodElement2 methodElement,
    ConstantReader method,
    bool formUrlEncoded,
  ) {
    final StringBuffer codeBuffer = StringBuffer('')..writeln('{');

    /// Search for @Header annotation in method parameters
    final Map<FormalParameterElement, ConstantReader> annotations =
        _getAnnotations(methodElement, chopper.Header);

    annotations.forEach((
      FormalParameterElement parameter,
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
      codeBuffer.writeln(
        "'content-type': 'application/x-www-form-urlencoded',",
      );
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
