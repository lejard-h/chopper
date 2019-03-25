import 'base_test.dart' as base;
import 'converter_test.dart' as converter;
import 'form_test.dart' as form;
import 'interceptors_test.dart' as interceptors;
import 'json_test.dart' as json;
import 'multipart_test.dart' as multipart;
import 'client_test.dart' as client;

main() {
  base.main();
  converter.main();
  interceptors.main();
  form.main();
  json.main();
  multipart.main();
  client.main();
}
