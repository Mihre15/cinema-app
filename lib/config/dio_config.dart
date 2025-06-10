import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

// Initialize Dio with proper configuration
final Dio dio = Dio(BaseOptions(
  baseUrl: 'http://10.0.2.2:3000',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
));

// Initialize cookie jar and add interceptor
void initializeDio() {
  try { 
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  } catch (e) {
    print('Error initializing Dio: $e');
  }
} 