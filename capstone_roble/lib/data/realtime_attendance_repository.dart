import 'package:firebase_database/firebase_database.dart';
import '../models/sessions.dart';
import 'attendance_repository.dart';

final RegExp _invalidKeyChars = RegExp(r'[.#$\[\]/]');

String safeKey(String value) => value.replaceAll(_invalidKeyChars, '_');

class RealtimeAttendanceRepository implements AttendanceRepository {
  DatabaseReference get _root => FirebaseDatabase.instance.ref();
  DatabaseReference get _sessionsRef => _root.child('sessions');
  DatabaseReference get _attendeesRef => _root.child('attendees');

  DateTime _toDate(Object? value) {
    final millis = value is num ? value.toInt() : 0;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Stream<List<Session>> watchSessions() {
    return _sessionsRef.onValue.map((event) {
      final value = event.snapshot.value;
      final list = <Session>[];
      if (value is Map) {
        value.forEach((key, data) {
          if (data is Map) {
            list.add(
              Session(
                id: key.toString(),
                title: (data['title'] ?? '').toString(),
                createdAt: _toDate(data['createdAt']),
                isOpen: data['isOpen'] != false,
              ),
            );
          }
        });
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Stream<List<Attendee>> watchAttendees(String sessionId) {
    return _attendeesRef.child(safeKey(sessionId)).onValue.map((event) {
      final value = event.snapshot.value;
      final list = <Attendee>[];
      if (value is Map) {
        value.forEach((key, data) {
          if (data is Map) {
            list.add(
              Attendee(
                studentId: (data['studentId'] ?? key).toString(),
                name: (data['name'] ?? '').toString(),
                scannedAt: _toDate(data['scannedAt']),
              ),
            );
          }
        });
      }
      list.sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
      return list;
    });
  }

  @override
  Future<Session> createSession(String title) async {
    final ref = _sessionsRef.push();
    final now = DateTime.now();
    await ref.set({
      'title': title,
      'createdAt': now.millisecondsSinceEpoch,
      'isOpen': true,
    });
    return Session(id: ref.key!, title: title, createdAt: now);
  }

  @override
  Future<void> renameSession(String sessionId, String title) {
    return _sessionsRef.child(safeKey(sessionId)).update({'title': title});
  }

  @override
  Future<void> closeSession(String sessionId) {
    return _sessionsRef.child(safeKey(sessionId)).update({'isOpen': false});
  }

  @override
  Future<void> reopenSession(String sessionId) {
    return _sessionsRef.child(safeKey(sessionId)).update({'isOpen': true});
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final key = safeKey(sessionId);
    await _attendeesRef.child(key).remove();
    await _sessionsRef.child(key).remove();
  }

  @override
  Future<void> markPresent(String sessionId, Attendee attendee) async {
    if (sessionId.isEmpty || _invalidKeyChars.hasMatch(sessionId)) {
      throw const AttendanceException('Unknown session. Is this the right code?');
    }
    final sessionSnap = await _sessionsRef.child(sessionId).get();
    if (!sessionSnap.exists || sessionSnap.value is! Map) {
      throw const AttendanceException('Unknown session. Is this the right code?');
    }
    final data = sessionSnap.value as Map;
    if (data['isOpen'] == false) {
      throw const AttendanceException('This session is already closed.');
    }
    final studentRef =
        _attendeesRef.child(sessionId).child(safeKey(attendee.studentId));
    final existing = await studentRef.get();
    if (existing.exists) {
      throw const AttendanceException('You are already marked present.');
    }
    await studentRef.set({
      'studentId': attendee.studentId,
      'name': attendee.name,
      'scannedAt': attendee.scannedAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> removeAttendee(String sessionId, String studentId) {
    return _attendeesRef
        .child(safeKey(sessionId))
        .child(safeKey(studentId))
        .remove();
  }
}