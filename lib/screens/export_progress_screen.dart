import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import './dashboard_screen.dart';

class ExportProgressScreen extends ConsumerWidget {
  const ExportProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchProvider);
    final theme = Theme.of(context);

    final allComplete = state.exportThreads.values.every((v) => v.status == 'Complete');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parallel Export Progress'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Master progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: state.overallProgress,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                  Text(
                    '${(state.overallProgress * 100).toInt()}%',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                allComplete 
                    ? 'Batch Completed Successfully!' 
                    : 'Executing Multithreaded Render...',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'AuraCut is building & watermarking vertical compositions.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),

              // Thread list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.exportThreads.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final key = state.exportThreads.keys.elementAt(index);
                  final thread = state.exportThreads[key]!;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffe5e3dd)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          thread.status == 'Complete'
                              ? Icons.check_circle
                              : thread.status == 'Failed'
                                  ? Icons.error
                                  : Icons.motion_photos_on_outlined,
                          color: thread.status == 'Complete'
                              ? const Color(0xff1c2d27)
                              : thread.status == 'Failed'
                                  ? Colors.red
                                  : const Color(0xff8c7853),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                thread.label,
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: thread.progress,
                                minHeight: 4,
                                backgroundColor: const Color(0xffe5e3dd),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  thread.status == 'Failed' ? Colors.red : const Color(0xff8c7853),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                thread.status,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Success steps or Error retry fallback
              if (allComplete) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff1c2d27).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, color: Color(0xff1c2d27)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Parallel render written directly to your Camera Roll via Gal.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xff1c2d27),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                children: [
                  if (allComplete) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Trigger native Gal/Photo library view action
                          try {
                            await Gal.open();
                          } catch (e) {
                            debugPrint('Unable to open photo library: $e');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(color: Color(0xffe5e3dd)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View in Photo Library'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        state.clearActiveWorkspace();
                        context.go('/');
                      },
                      child: const Text('Start New Batch'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
