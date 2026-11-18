import 'package:capstone_roble/models/sessions.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../data/attendance_repository.dart';
import '../format.dart';
import '../theme.dart';
import '../widgets/animations.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late final Stream<List<Session>> _sessions = repository.watchSessions();
  late final Stream<List<Attendee>> _attendees =
      repository.watchAttendees(widget.sessionId);
  int _testCount = 0;

  Future<void> _addTestStudent() async {
    _testCount++;
    await repository.markPresent(
      widget.sessionId,
      Attendee(
        studentId: 'TEST-$_testCount',
        name: 'Test Student $_testCount',
        scannedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _confirmClose() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close session?'),
        content: const Text('Students will no longer be able to check in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, 44),
              backgroundColor: AppColors.pink,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repository.closeSession(widget.sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Session>>(
      stream: _sessions,
      builder: (context, sessionSnap) {
        if (!sessionSnap.hasData) return const Scaffold();
        final matches =
            sessionSnap.data!.where((s) => s.id == widget.sessionId);
        if (matches.isEmpty) return const Scaffold();
        final session = matches.first;

        return Scaffold(
          bottomNavigationBar: session.isOpen
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addTestStudent,
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Test scan'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _confirmClose,
                            icon: const Icon(Icons.lock_rounded),
                            label: const Text('Close'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: StreamBuilder<List<Attendee>>(
            stream: _attendees,
            builder: (context, attSnap) {
              final attendees = attSnap.data ?? [];
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        gradient:
                            session.isOpen ? AppColors.hero : AppColors.closed,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(40),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 32),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      session.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedOpacity(
                                    opacity: session.isOpen ? 1 : 0.15,
                                    duration: const Duration(milliseconds: 400),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 24,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: QrImageView(
                                        data: session.id,
                                        version: QrVersions.auto,
                                        size: 220,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.circle,
                                          color: Color(0xFF4A148C),
                                        ),
                                        dataModuleStyle:
                                            const QrDataModuleStyle(
                                          dataModuleShape:
                                              QrDataModuleShape.square,
                                          color: Color(0xFF4A148C),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!session.isOpen)
                                    const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.lock_rounded,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Session closed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                session.isOpen
                                    ? 'Students scan this to mark present'
                                    : 'No more check-ins allowed',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        children: [
                          const Text(
                            'Present',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Container(
                              key: ValueKey(attendees.length),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.ocean,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${attendees.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (attendees.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_top_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Waiting for students to scan...',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final a = attendees[i];
                            final color = AppColors
                                .palette[i % AppColors.palette.length];
                            return FadeSlideIn(
                              key: ValueKey(a.studentId),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: color,
                                      child: Text(
                                        a.name.isEmpty
                                            ? '?'
                                            : a.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      a.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text('ID ${a.studentId}'),
                                    trailing: Text(
                                      formatTime(a.scannedAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: attendees.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}