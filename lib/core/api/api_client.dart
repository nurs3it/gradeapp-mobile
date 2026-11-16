import 'dart:async';

import 'package:dio/dio.dart';

import '../env.dart';
import '../json.dart';
import 'session_store.dart';

/// Builds the app's Dio: bearer token on every call, one shared refresh on 401.
///
/// The refresh token may come back in the body (default) or — when the backend
/// runs with `AUTH_REFRESH_COOKIE_ENABLED` — only as a `ga_rt_<sid>` cookie.
/// Both are handled: the cookie value is lifted into the store and sent back
/// as `refresh` in the body, which the backend also accepts.
class ApiClient {
  ApiClient(this.sessions, {required this.onSessionLost}) : dio = Dio(_options()), _raw = Dio(_options()) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: _attachToken, onError: _onError));
  }

  final SessionStore sessions;
  final Dio dio;

  /// Fired once when the server rejects the refresh token (sign-out).
  final void Function() onSessionLost;

  final Dio _raw; // no interceptors: used for login / refresh
  Future<String>? _refreshing;

  static BaseOptions _options() => BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
  );

  /// POST /auth/login/. Throws [OtpRequired] when 2FA is on and no code given.
  Future<Json> login(String email, String password, {String? otp}) async {
    try {
      final res = await _raw.post<Json>('/auth/login/', data: {'email': email, 'password': password, 'otp': ?otp});
      await _storeTokens(res);
      return res.data!;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && body['otp_required'] != null) throw const OtpRequired();
      rethrow;
    }
  }

  /// POST /auth/access-code/: one-time code from the school. The code is
  /// spent atomically, so the new password travels in the same request.
  /// The response carries `login` — the address to sign in with later.
  Future<Json> redeemAccessCode(String code, {String? newPassword, String? otp}) async {
    try {
      final res = await _raw.post<Json>(
        '/auth/access-code/',
        data: {'code': code, 'new_password': ?newPassword, 'otp': ?otp},
      );
      await _storeTokens(res);
      return res.data!;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && body['otp_required'] != null) throw const OtpRequired();
      rethrow;
    }
  }

  /// POST /auth/password-reset/ — always answers neutrally.
  Future<void> requestPasswordReset(String email) =>
      _raw.post<void>('/auth/password-reset/', data: {'email': email});

  Future<void> logout() async {
    final s = sessions.current;
    if (s != null) {
      await _raw
          .post<void>('/auth/logout/', data: {'session_id': s.sessionId, 'refresh': s.refresh})
          .catchError((_) => Response<void>(requestOptions: RequestOptions()));
    }
    await sessions.clear();
  }

  void _attachToken(RequestOptions o, RequestInterceptorHandler h) {
    final token = sessions.current?.access;
    if (token != null && token.isNotEmpty) {
      o.headers['Authorization'] = 'Bearer $token';
    }
    h.next(o);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler h) async {
    final o = e.requestOptions;
    if (e.response?.statusCode != 401 || o.extra['retried'] == true) {
      return h.next(e);
    }
    try {
      final access = await refreshAccess();
      o.extra['retried'] = true;
      o.headers['Authorization'] = 'Bearer $access';
      h.resolve(await dio.fetch<dynamic>(o));
    } on DioException catch (err) {
      h.next(err);
    } catch (_) {
      h.next(e);
    }
  }

  /// Single in-flight refresh: N parallel 401s share one rotation, otherwise
  /// the backend sees the same refresh token twice and revokes the session.
  Future<String> refreshAccess() => _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<String> _doRefresh() async {
    final s = sessions.current;
    if (s == null) throw StateError('no session');
    try {
      final res = await _raw.post<Json>('/auth/refresh/', data: {'session_id': s.sessionId, 'refresh': s.refresh});
      return (await _storeTokens(res)).access;
    } on DioException catch (e) {
      // Only an explicit 401 ends the session; a network blip must not.
      if (e.response?.statusCode == 401) {
        await sessions.clear();
        onSessionLost();
      }
      rethrow;
    }
  }

  Future<Session> _storeTokens(Response<Json> res) async {
    final body = res.data!;
    final sid = body.str('session_id');
    final refresh =
        body.strOrNull('refresh') ??
        _cookie(res.headers['set-cookie'], 'ga_rt_$sid') ??
        sessions.current?.refresh ??
        '';
    final s = Session(access: body.str('access'), refresh: refresh, sessionId: sid);
    await sessions.save(s);
    return s;
  }

  static String? _cookie(List<String>? setCookie, String name) {
    for (final c in setCookie ?? const <String>[]) {
      final first = c.split(';').first;
      final eq = first.indexOf('=');
      if (eq > 0 && first.substring(0, eq).trim() == name) {
        return first.substring(eq + 1);
      }
    }
    return null;
  }
}

class OtpRequired implements Exception {
  const OtpRequired();
}

/// True when the request never reached the server (offline, timeout, DNS).
bool isOffline(Object e) =>
    e is DioException &&
    e.response == null &&
    e.type != DioExceptionType.cancel &&
    e.type != DioExceptionType.badCertificate;
