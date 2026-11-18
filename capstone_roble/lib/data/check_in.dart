import '../models/sessions.dart';
import 'attendance_repository.dart';

Future<String?> checkIn(
  String sessionId,
  String name,
  String studentId,
) async {
  try {
    await repository.markPresent(
      sessionId.trim(),
      Attendee(
        studentId: studentId.trim(),
        name: name.trim(),
        scannedAt: DateTime.now(),
      ),
    );
    return null;
  } on AttendanceException catch (e) {
    return e.message;
  } catch (_) {
    return 'Something went wrong. Check your connection and try again.';
  }
}