import 'dart:async';
import 'package:capstone_roble/models/sessions.dart';


abstract class AttendanceRepository {
  Stream<List<Session>> watchSessions();
  Stream<List<Attendee>> watchAttendees(String sessionId);
  Future<Session> createSession(String title);
  Future<void> closeSession(String sessionId);
  Future<void> markPresent(String sessionId, Attendee attendee);
}

class InMemoryAttendanceRepository implements AttendanceRepository {
  final List<Session> _sessions = [];
  final Map<String, Map<String, Attendee>> _attendees = {};
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<Session>> watchSessions() async* {
    yield _sessions.reversed.toList();
    await for (final _ in _changes.stream) {
      yield _sessions.reversed.toList();
    }
  }

  @override
  Stream<List<Attendee>> watchAttendees(String sessionId) async* {
    List<Attendee> current() => (_attendees[sessionId]?.values.toList() ?? [])
      ..sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
    yield current();
    await for (final _ in _changes.stream) {
      yield current();
    }
  }

  @override
  Future<Session> createSession(String title) async {
    final session = Session(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    _sessions.add(session);
    _attendees[session.id] = {};
    _changes.add(null);
    return session;
  }

  @override
  Future<void> closeSession(String sessionId) async {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return;
    _sessions[i] = _sessions[i].copyWith(isOpen: false);
    _changes.add(null);
  }

  @override
  Future<void> markPresent(String sessionId, Attendee attendee) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    if (!session.isOpen) throw StateError('Session is closed');
    _attendees[sessionId]![attendee.studentId] = attendee;
    _changes.add(null);
  }
}

extension on Object? {

}

final AttendanceRepository repository = InMemoryAttendanceRepository();