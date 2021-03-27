const contentTypeKey = 'content-type';
const jsonHeaders = 'application/json';
const formEncodedHeaders = 'application/x-www-form-urlencoded';

// Represent the header for a json api response https://jsonapi.org/#mime-types
const jsonApiHeaders = 'application/vnd.api+json';

class HttpMethod {
  static const String Get = 'GET';
  static const String Post = 'POST';
  static const String Put = 'PUT';
  static const String Delete = 'DELETE';
  static const String Patch = 'PATCH';
  static const String Head = 'HEAD';
  static const String Options = 'OPTIONS';
}
