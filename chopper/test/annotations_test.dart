// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:test/test.dart';

part 'annotations_test.chopper.dart';

@ChopperApi(baseUrl: '/test')
abstract class DeprecatedAnnotationService extends ChopperService {
  @Get(path: '/get')
  Future<Response<String>> testGet();

  @Post(path: '/post')
  Future<Response<dynamic>> testPost(@Body() dynamic body);

  @Put(path: '/put')
  Future<Response<dynamic>> testPut(@Body() dynamic body);

  @Patch(path: '/patch')
  Future<Response<dynamic>> testPatch(@Body() dynamic body);

  @Delete(path: '/delete')
  Future<Response<dynamic>> testDelete();

  @Head(path: '/head')
  Future<Response<dynamic>> testHead();

  @Options(path: '/options')
  Future<Response<dynamic>> testOptions();
}

@ChopperApi(baseUrl: '/shorthand')
abstract class ShorthandAnnotationService extends ChopperService {
  @get
  Future<Response<dynamic>> testGetShorthand();

  @post
  Future<Response<dynamic>> testPostShorthand(@body dynamic body);

  @put
  Future<Response<dynamic>> testPutShorthand(@body dynamic body);

  @patch
  Future<Response<dynamic>> testPatchShorthand(@body dynamic body);

  @delete
  Future<Response<dynamic>> testDeleteShorthand();

  @head
  Future<Response<dynamic>> testHeadShorthand();

  @options
  Future<Response<dynamic>> testOptionsShorthand();

  @Get(path: '/{id}')
  Future<Response<dynamic>> testPathShorthand(@path String id);

  @Get(path: '/query')
  Future<Response<dynamic>> testQueryShorthand(@query String name);

  @Get(path: '/queryMap')
  Future<Response<dynamic>> testQueryMapShorthand(
    @queryMap Map<String, dynamic> map,
  );

  @Get(path: '/header')
  Future<Response<dynamic>> testHeaderShorthand(@header String testHeader);

  @Post(path: '/field')
  @formUrlEncoded
  Future<Response<dynamic>> testFieldShorthand(@field String data);

  @Post(path: '/fieldMap')
  @formUrlEncoded
  Future<Response<dynamic>> testFieldMapShorthand(
    @fieldMap Map<String, dynamic> data,
  );

  @Post(path: '/multipart')
  @multipart
  Future<Response<dynamic>> testPartShorthand(@part String data);

  @Post(path: '/partFile')
  @multipart
  Future<Response<dynamic>> testPartFileShorthand(@partFile List<int> data);

  @Post(path: '/partMap')
  @multipart
  Future<Response<dynamic>> testPartMapShorthand(@partMap List<PartValue> data);

  @Post(path: '/partFileMap')
  @multipart
  Future<Response<dynamic>> testPartFileMapShorthand(
    @partFileMap List<PartValueFile> data,
  );

  @Get(path: '/tag')
  Future<Response<dynamic>> testTagShorthand(@tag String myTag);
}

void main() {
  group('Annotation Instantiation Tests', () {
    test('Deprecated method annotations can be instantiated', () {
      expect(const Get(), isA<Get>());
      expect(const Post(), isA<Post>());
      expect(const Put(), isA<Put>());
      expect(const Patch(), isA<Patch>());
      expect(const Delete(), isA<Delete>());
      expect(const Head(), isA<Head>());
      expect(const Options(), isA<Options>());
    });

    test('Shorthand method annotations can be instantiated', () {
      expect(get, isA<GET>());
      expect(post, isA<POST>());
      expect(put, isA<PUT>());
      expect(patch, isA<PATCH>());
      expect(delete, isA<DELETE>());
      expect(head, isA<HEAD>());
      expect(options, isA<OPTIONS>());
    });

    test('Shorthand parameter annotations can be instantiated', () {
      expect(body, isA<Body>());
      expect(path, isA<Path>());
      expect(query, isA<Query>());
      expect(queryMap, isA<QueryMap>());
      expect(header, isA<Header>());
      expect(field, isA<Field>());
      expect(fieldMap, isA<FieldMap>());
      expect(part, isA<Part>());
      expect(partMap, isA<PartMap>());
      expect(partFile, isA<PartFile>());
      expect(partFileMap, isA<PartFileMap>());
      expect(tag, isA<Tag>());
    });

    test('Shorthand class/misc annotations can be instantiated', () {
      expect(chopperApi, isA<ChopperApi>());
      expect(multipart, isA<Multipart>());
      expect(formUrlEncoded, isA<FormUrlEncoded>());
      expect(factoryConverter, isA<FactoryConverter>());
    });

    // Test constructor argument passing for deprecated annotations
    test('Deprecated GET with all arguments', () {
      const annotation = GET(
        path: '/all',
        optionalBody: false,
        headers: {'X-Test': 'true'},
        listFormat: ListFormat.comma,
        // Corrected from .csv
        useBrackets: true,
        includeNullQueryVars: true,
        timeout: Duration(seconds: 10),
      );
      expect(annotation.path, '/all');
      expect(annotation.optionalBody, false);
      expect(annotation.headers['X-Test'], 'true');
      expect(annotation.listFormat, ListFormat.comma); // Corrected from .csv
      expect(annotation.useBrackets, true);
      expect(annotation.includeNullQueryVars, true);
      expect(annotation.timeout, const Duration(seconds: 10));
    });

    // Test constructor argument passing for main annotations (GET used as example)
    // This also covers the base Method class constructor
    test('Method (GET) with all arguments', () {
      const annotation = GET(
        path: '/allArgs',
        optionalBody: false,
        headers: {'X-Full-Test': 'yes'},
        listFormat: ListFormat.indices,
        useBrackets: false,
        // Deliberately different from deprecated
        includeNullQueryVars: false,
        timeout: Duration(milliseconds: 500),
      );
      expect(annotation.path, '/allArgs');
      expect(annotation.optionalBody, false);
      expect(annotation.headers['X-Full-Test'], 'yes');
      expect(annotation.listFormat, ListFormat.indices);
      expect(annotation.useBrackets, false);
      expect(annotation.includeNullQueryVars, false);
      expect(annotation.timeout, const Duration(milliseconds: 500));
    });

    test('Method (GET) with default arguments', () {
      const annotation = GET();
      expect(annotation.path, '');
      expect(annotation.optionalBody, true);
      expect(annotation.headers, const {});
      expect(annotation.listFormat, null);
      expect(annotation.useBrackets, null); // Changed from false to null
      expect(
        annotation.includeNullQueryVars,
        null,
      ); // Changed from false to null
      expect(annotation.timeout, null);
    });

    test('Path with name', () {
      const p = Path('id');
      expect(p.name, 'id');
    });

    test('Query with name', () {
      const q = Query('name');
      expect(q.name, 'name');
    });

    test('Header with name', () {
      const h = Header('X-Custom-Header');
      expect(h.name, 'X-Custom-Header');
    });

    test('Field with name', () {
      const f = Field('dataField');
      expect(f.name, 'dataField');
    });

    test('Field with default name', () {
      const f = Field();
      expect(f.name, null);
    });

    test('Part with name', () {
      const p = Part('filePart');
      expect(p.name, 'filePart');
    });

    test('Part with default name', () {
      const p = Part();
      expect(p.name, null);
    });

    test('PartFile with name', () {
      const pf = PartFile('imageFile');
      expect(pf.name, 'imageFile');
    });

    test('PartFile with default name', () {
      const pf = PartFile();
      expect(pf.name, null);
    });

    test('FactoryConverter with request and response', () {
      FutureOr<Request> reqConv(Request r) => r;
      FutureOr<Response> resConv(Response r) => r;
      final fc = FactoryConverter(
        request: reqConv,
        response: resConv,
      ); // Changed to final
      expect(fc.request, reqConv);
      expect(fc.response, resConv);
    });
  });
}
