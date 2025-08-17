import 'package:dio/dio.dart';
import 'package:pedeai/Commom/endpoints.dart';
import 'package:pedeai/abstractClasses/AbstractHttpService.dart';

class IHttpService implements AbstractHttpService {
  const IHttpService();

  /*Future<Dio> _dio() async {
    var prefs = await SharedPreferences.getInstance();
    var nomeWebSocketAtual = prefs.getString('WebSocketSelecionado')!;
    return Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        headers: {
        "applicationId": nomeWebSocketAtual,
        "content-type": "application/json",
      },
        connectTimeout:const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 90),
      ),
    )..interceptors.add(CustomDioInterceptors(prefs));
  }*/

  @override
  Future<Response> delete({required String url, data, required String nomeWebSocketAtual, required String schema}) async {
    try {
      Dio dio = Dio(_getDioOptions(nomeWebSocketAtual, schema));
      var response = await dio.delete(
        url,
        data: data,
        options: Options(headers: _getOptions(nomeWebSocketAtual, schema)),
      );
      return response;
    } catch (e) {
      return throw Exception(e);
    }
    /* try {
      var dio = await _dio();
      var response = await dio.delete(url, queryParameters: data);
      return response;
    } catch (e) {
      return throw Exception(e);
    }*/
  }

  @override
  Future<Response> get({required String url, queryParameters, required String nomeWebSocketAtual, required String schema}) async {
    try {
      Dio dio = Dio(_getDioOptions(nomeWebSocketAtual, schema));
      var response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: _getOptions(nomeWebSocketAtual, schema)),
      );
      return response;
    } catch (e) {
      return throw Exception(e);
    }
    /*try {
      var dio = await _dio();
      var response = await dio.get(
        url,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      return throw Exception(e);
    }*/
  }

  @override
  Future<Response> post({required String url, data, required String nomeWebSocketAtual, required String schema}) async {
    try {
      Dio dio = Dio(_getDioOptions(nomeWebSocketAtual, schema));
      var response = await dio.post(
        url,
        data: data,
        options: Options(headers: _getOptions(nomeWebSocketAtual, schema)),
      );
      return response;
    } catch (e) {
      return throw Exception(e);
    }
  }

  @override
  Future<Response> put({required String url, data, required String nomeWebSocketAtual, required String schema}) async {
    try {
      Dio dio = Dio(_getDioOptions(nomeWebSocketAtual, schema));
      var response = await dio.put(
        url,
        data: data,
        options: Options(headers: _getOptions(nomeWebSocketAtual, schema)),
      );
      return response;
    } catch (e) {
      return throw Exception(e);
    }
    /* try {
      var dio = await _dio();
      var response = await dio.put(url, data: data);
      return response;
    } catch (e) {
      return throw Exception(e);
    }*/
  }

  @override
  Future<Response> patch({required String url, data, required String nomeWebSocketAtual, required String schema}) async {
    try {
      Dio dio = Dio(_getDioOptions(nomeWebSocketAtual, schema));
      var response = await dio.patch(
        url,
        data: data,
        options: Options(headers: _getOptions(nomeWebSocketAtual, schema)),
      );
      return response;
    } catch (e) {
      return throw Exception(e);
    }
    /*try {
      var dio = await _dio();
      var response = await dio.patch(url, data: data);
      return response;
    } catch (e) {
      print('erro patch $e');
      return throw Exception(e);
    }*/
  }

  BaseOptions? _getDioOptions(String nomeWebSocketAtual, String schema) {
    return BaseOptions(
      baseUrl: Endpoints.baseUrl,
      headers: {"applicationId": "$nomeWebSocketAtual-PedeAiERP", "content-type": "application/json", "X-Schema": schema},
      //connectTimeout: const Duration(seconds: 60).inSeconds,
      //receiveTimeout: const Duration(seconds: 60).inSeconds,
      //sendTimeout: const Duration(seconds: 60).inSeconds,
    );
  }

  Map<String, dynamic>? _getOptions(String nomeWebSocketAtual, String schema) {
    return {"applicationId": "$nomeWebSocketAtual-PedeAiERP", "content-type": "application/json", "X-Schema": schema};
  }
}
