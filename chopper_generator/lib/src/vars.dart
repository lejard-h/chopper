enum Vars {
  client('client'),
  response(r'$response'),
  baseUrl('baseUrl'),
  parameters(r'$params'),
  headers(r'$headers'),
  request(r'$request'),
  body(r'$body'),
  parts(r'$parts'),
  url(r'$url');

  const Vars(this.name);

  final String name;

  @override
  String toString() => name;
}
