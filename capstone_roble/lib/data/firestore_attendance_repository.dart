import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sessions.dart';
import 'attendance_repository.dart';

class FirestoreAttendanceRepository implements AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');

  Session _toSession(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Session(
      id: doc.id,
      title: data['title'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOpen: data['isOpen'] as bool? ?? true,
    );
  }

  @override
  Stream<List<Session>> watchSessions() {
    return _sessions
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_toSession).toList());
  }

  @override
  Stream<List<Attendee>> watchAttendees(String sessionId) {
    return _sessions
        .doc(sessionId)
        .collection('attendees')
        .orderBy('scannedAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return Attendee(
              studentId: d.id,
              name: data['name'] as String? ?? '',
              scannedAt:
                  (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList(),
        );
  }

  @override
  Future<Session> createSession(String title) async {
    final createdAt = DateTime.now();
    final ref = await _sessions.add({
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'isOpen': true,
    });
    return Session(id: ref.id, title: title, createdAt: createdAt);
  }

  @override
  Future<void> closeSession(String sessionId) async {
    await _sessions.doc(sessionId).update({'isOpen': false});
  }

  @override
  Future<void> markPresent(String sessionId, Attendee attendee) async {
    if (sessionId.isEmpty || sessionId.contains('/')) {
      throw const AttendanceException('Unknown session. Is this the right QR?');
    }
    if (attendee.studentId.contains('/')) {
      throw const AttendanceException('Student ID cannot contain "/".');
    }

    final sessionRef = _sessions.doc(sessionId);
    final attendeeRef =
        sessionRef.collection('attendees').doc(attendee.studentId);

    await _db.runTransaction((tx) async {
      final session = await tx.get(sessionRef);
      if (!session.exists) {
        throw const AttendanceException('Unknown session. Is this the right QR?');
      }
      if (session.data()?['isOpen'] != true) {
        throw const AttendanceException('This session is already closed.');
      }
      final existing = await tx.get(attendeeRef);
      if (existing.exists) {
        throw const AttendanceException('You are already marked present.');
      }
      tx.set(attendeeRef, {
        'name': attendee.name,
        'scannedAt': Timestamp.fromDate(attendee.scannedAt),
      });
    });
  }
}