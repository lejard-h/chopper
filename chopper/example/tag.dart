import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

part 'tag.chopper.dart';

Future<void> main() async {
  final chopper = ChopperClient(
    client: MockClient((request) async {
      return http.Response(
        'path=${request.url.path}; appId=${request.headers['x-app-id']}',
        200,
      );
    }),
    baseUrl: Uri.parse('http://localhost:8000'),
    services: [
      // the generated service
      TagService.create(),
    ],
    interceptors: [TagInterceptor()],
    converter: TagConverter(),
  );

  final tagService = chopper.getService<TagService>();

  final response = await tagService.requestWithTag(
    tag: const BizTag(appId: 42),
  );
  print(response.body);
  chopper.dispose();
}

// add a uniform appId header for some path
class BizTag {
  final int appId;

  const BizTag({this.appId = 0});
}

class IncludeBodyNullOrEmptyTag {
  final bool includeNull;
  final bool includeEmpty;

  const IncludeBodyNullOrEmptyTag({
    this.includeNull = false,
    this.includeEmpty = false,
  });
}

class TagConverter extends JsonConverter {
  @override
  Request convertRequest(Request request) {
    final tag = request.tag;
    if (tag is IncludeBodyNullOrEmptyTag) {
      if (request.body is Map) {
        final Map body = request.body as Map;
        final Map bodyCopy = {};
        for (final MapEntry entry in body.entries) {
          if (!tag.includeNull && entry.value == null) continue;
          if (!tag.includeEmpty && entry.value == '') continue;
          bodyCopy[entry.key] = entry.value;
        }
        request = request.copyWith(body: bodyCopy);
      }
    }

    return super.convertRequest(request);
  }
}

class TagInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    final request = chain.request;
    final tag = request.tag;
    if (tag is BizTag) {
      return chain.proceed(
        applyHeader(request, 'x-app-id', tag.appId.toString()),
      );
    }

    return chain.proceed(request);
  }
}

@ChopperApi(baseUrl: '/tag')
abstract class TagService extends ChopperService {
  static TagService create([ChopperClient? client]) => _$TagService(client);

  @GET(path: '/bizRequest')
  Future<Response> requestWithTag({@Tag() BizTag tag = const BizTag()});

  @GET(path: '/include')
  Future<Response> includeBodyNullOrEmptyTag({
    @Tag() IncludeBodyNullOrEmptyTag tag = const IncludeBodyNullOrEmptyTag(),
  });
}
