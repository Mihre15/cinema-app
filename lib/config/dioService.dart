
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  late Dio dio;

  factory DioService() => _instance;

  DioService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:3000',
      connectTimeout: const Duration(seconds: 5),
    ));

    // Configure interceptors
    dio.interceptors.add(CookieManager(CookieJar()));
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('Sending request to ${options.path}');
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          // You might want to navigate to login here
        }
        return handler.next(error);
      },
    ));
  }
}