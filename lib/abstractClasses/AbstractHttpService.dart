import 'package:dio/dio.dart';

abstract class AbstractHttpService {
  Future<Response> post({required String url, dynamic data, required String nomeWebSocketAtual, required String schema});
  Future<Response> get({required String url, dynamic queryParameters, required String nomeWebSocketAtual, required String schema});
  Future<Response> delete({required String url, dynamic data, required String nomeWebSocketAtual, required String schema});
  Future<Response> put({required String url, dynamic data, required String nomeWebSocketAtual, required String schema});
}
