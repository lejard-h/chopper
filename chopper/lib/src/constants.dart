// ignore_for_file: constant_identifier_names

const String contentTypeKey = 'content-type';
const String jsonHeaders = 'application/json';
const String formEncodedHeaders = 'application/x-www-form-urlencoded';

// Represent the header for a json api response https://jsonapi.org/#mime-types
const String jsonApiHeaders = 'application/vnd.api+json';

abstract final class HttpMethod {
  static const String Get = 'GET';
  static const String Post = 'POST';
  static const String Put = 'PUT';
  static const String Delete = 'DELETE';
  static const String Patch = 'PATCH';
  static const String Head = 'HEAD';
  static const String Options = 'OPTIONS';
}
