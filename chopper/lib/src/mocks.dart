import 'package:chopper/src/base.dart';
import 'package:chopper/src/chopper_log_record.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:mockito/mockito.dart';

base class MockChopperClient extends Mock with MockChopperClientMixin {}

base class MockChopperLogRecord extends Mock with MockChopperLogRecordMixin {}

base class MockRequest extends Mock with MockRequestMixin {}

base class MockPartValue<T> extends Mock with MockPartValueMixin<T> {}

base class MockPartValueFile<T> extends Mock with MockPartValueFileMixin<T> {}

base class MockResponse extends Mock with MockResponseMixin {}
