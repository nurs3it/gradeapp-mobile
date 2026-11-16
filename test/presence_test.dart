import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/providers.dart';
import 'package:gradeapp/features/auth/auth_controller.dart';
import 'package:gradeapp/features/auth/user.dart';
import 'package:gradeapp/features/common/presence.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.answer);
  final ResponseBody Function(RequestOptions o) answer;
  final calls = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    calls.add(o);
    return answer(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

class _Auth extends AuthController {
  @override
  Future<AppUser?> build() async =>
      const AppUser(id: 'me', email: 'a@b.c', firstName: 'A', lastName: 'B', roles: ['student']);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PresenceBatcher', () {
    test('ids of the same avatar count once and go out comma-joined per kind', () {
      final b = PresenceBatcher()
        ..add(const PresenceRef.user('u1'))
        ..add(const PresenceRef.student('s1'))
        ..add(const PresenceRef.student('s2'));
      expect(b.add(const PresenceRef.student('s1')), isFalse);
      expect(b.queries(), [
        {'users': 'u1', 'students': 's1,s2'},
      ]);
    });

    test('an id leaves the batch only after its last avatar is gone', () {
      final b = PresenceBatcher()
        ..add(const PresenceRef.staff('t1'))
        ..add(const PresenceRef.staff('t1'))
        ..remove(const PresenceRef.staff('t1'));
      expect(b.wanted, {const PresenceRef.staff('t1')});
      b.remove(const PresenceRef.staff('t1'));
      expect(b.isEmpty, isTrue);
      expect(b.queries(), isEmpty);
    });

    test('lists over 200 ids spill into further requests', () {
      final b = PresenceBatcher();
      for (var i = 0; i < 450; i++) {
        b.add(PresenceRef.student('s$i'));
      }
      b.add(const PresenceRef.user('u'));
      final q = b.queries();
      expect(q, hasLength(3));
      expect(q[0]['students']!.split(','), hasLength(200));
      expect(q[1]['students']!.split(','), hasLength(200));
      expect(q[2]['students']!.split(','), hasLength(50));
      expect(q[0]['users'], 'u');
      expect(q[1].containsKey('users'), isFalse);
    });

    test('parses the answer, ignores junk', () {
      expect(
        PresenceBatcher.parse({
          'users': ['u1'],
          'students': ['s1', 5],
          'staff': <String>[],
        }),
        {const PresenceRef.user('u1'), const PresenceRef.student('s1')},
      );
      expect(PresenceBatcher.parse(null), isEmpty);
      expect(PresenceBatcher.parse('x'), isEmpty);
    });
  });

  group('PresenceController', () {
    Future<(ProviderContainer, _Adapter)> setup(ResponseBody Function(RequestOptions) answer) async {
      final adapter = _Adapter(answer);
      final dio = Dio(BaseOptions(baseUrl: 'http://x/api'))..httpClientAdapter = adapter;
      final c = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio), authProvider.overrideWith(_Auth.new)],
      );
      addTearDown(c.dispose);
      await c.read(authProvider.future);
      return (c, adapter);
    }

    test('many avatars on screen make one request and light the online ones', () async {
      final (c, a) = await setup(
        (_) => _json({
          'users': <String>[],
          'students': ['s1'],
          'staff': <String>[],
        }),
      );
      final p = c.read(presenceProvider.notifier);
      p
        ..acquire(const PresenceRef.student('s1'))
        ..acquire(const PresenceRef.student('s2'))
        ..acquire(const PresenceRef.user('me'));
      await p.refresh();
      expect(a.calls, hasLength(1));
      expect(a.calls.single.path, '/presence/');
      expect(a.calls.single.queryParameters, {'users': 'me', 'students': 's1,s2'});
      expect(c.read(presenceProvider), {const PresenceRef.student('s1')});
      p.release(const PresenceRef.student('s1'));
      await p.refresh();
      expect(c.read(presenceProvider), isEmpty);
    });

    test('a 404 keeps the dots off and stops asking for a while', () async {
      final (c, a) = await setup((_) => _json({'detail': 'nope'}, 404));
      final p = c.read(presenceProvider.notifier)..acquire(const PresenceRef.user('me'));
      await p.refresh();
      await p.refresh();
      expect(a.calls, hasLength(1));
      expect(c.read(presenceProvider), isEmpty);
    });
  });
}
