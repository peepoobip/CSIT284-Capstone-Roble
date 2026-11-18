class Session {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool isOpen;

  const Session({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isOpen = true,
  });

  Session copyWith({bool? isOpen}) => Session(
        id: id,
        title: title,
        createdAt: createdAt,
        isOpen: isOpen ?? this.isOpen,
      );
}

class Attendee {
  final String studentId;
  final String name;
  final DateTime scannedAt;

  const Attendee({
    required this.studentId,
    required this.name,
    required this.scannedAt,
  });
}