/// @author luwenjie on 2024/3/20 11:38:11
///
///
///
import "package:chopper/chopper.dart";

import 'definition.dart';

part 'tag.chopper.dart';

Future<void> main() async {
  final chopper = ChopperClient(
    baseUrl: Uri.parse('http://localhost:8000'),
    services: [
      // the generated service
      TagService.create(ChopperClient()),
    ],
    interceptors: [
      TagInterceptor(),
    ],
    converter: JsonConverter(),
  );

  final myService = chopper.getService<MyService>();

  final response = await myService.getMapResource('1');
  print(response.body);

  final list = await myService.getListResources();
  print(list.body);
  chopper.dispose();
}

// add a uniform appId header for some path
class BizTag {
  final int appId;

  BizTag({this.appId = 0});
}

class IncludeBodyNullOrEmptyTag {
  bool includeNull = false;
  bool includeEmpty = false;

  IncludeBodyNullOrEmptyTag(this.includeNull, this.includeEmpty);
}

class TagConverter extends JsonConverter {
  FutureOr<Request> convertRequest(Request request) {
    final tag = request.tag;
    if (tag is IncludeBodyNullOrEmptyTag) {
      if (request.body is Map) {
        final Map body = request.body as Map;
        final Map bodyCopy = {};
        for (final MapEntry entry in body.entries) {
          if (!tag.includeNull && entry.value == null) continue;
          if (!tag.includeEmpty && entry.value == "") continue;
          bodyCopy[entry.key] = entry.value;
        }
        request = request.copyWith(body: bodyCopy);
      }
    }
  }
}

class TagInterceptor implements RequestInterceptor {
  FutureOr<Request> onRequest(Request request) {
    final tag = request.tag;
    if (tag is BizTag) {
      request.headers["x-appId"] = tag.appId;
    }
    return request;
  }
}

@ChopperApi(baseUrl: '/tag')
abstract class TagService extends ChopperService {
  static TagService create(ChopperClient client) => _$TagService(client);

  @get(path: '/bizRequest')
  Future<Response> requestWithTag({@Tag() BizTag tag = const BizTag()});

  @get(path: '/include')
  Future<Response> includeBodyNullOrEmptyTag(
      {@Tag()
      IncludeBodyNullOrEmptyTag tag = const IncludeBodyNullOrEmptyTag()});
}
