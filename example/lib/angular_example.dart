import 'package:angular/angular.dart';
import 'package:chopper/chopper.dart';
import 'package:chopper_example/definition.dart';

// ignore: uri_has_not_been_generated
import 'angular_example.template.dart' as ng;

final appFactory = ng.ChopperExampleComponentNgFactory;

MyService serviceFactory(ChopperClient client) => MyService.create(client);

@Component(
  selector: 'app-component',
  template: '{{client}} {{service}}',
  providers: [FactoryProvider<MyService>(MyService, serviceFactory)],
)
class ChopperExampleComponent {
  final ChopperClient client;
  final MyService service;

  ChopperExampleComponent(this.client, this.service);
}
