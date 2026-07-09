import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './dashboard_screen.dart';
import '../models/video_configuration.dart';

class TemplateSelectionScreen extends ConsumerWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retention Templates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select High-Retention Layout',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Every layout is engineered with high-retention hooks proven to engage scrolling social audiences.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal card slider
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.templates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final t = state.templates[index];
                  final isSelected = state.selectedTemplate?.id == t.id;
                  return GestureDetector(
                    onTap: () => state.selectTemplate(t),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff1c2d27) : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xff1c2d27) : const Color(0xffe5e3dd),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xff8c7853).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  t.targetPlatform,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : const Color(0xff8c7853),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            t.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.retentionMetric,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected ? const Color(0xff8c7853) : const Color(0xff1c2d27),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // AI Voice Selector
            Text(
              'Voiceover & Audio Variables',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Narrator Voice',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AiVoice>(
                      initialValue: state.selectedVoice,
                      items: state.voices.map((v) {
                        return DropdownMenuItem<AiVoice>(
                          value: v,
                          child: Text('${v.name} (${v.accent})'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) state.selectVoice(v);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.record_voice_over_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Synced Music Beat',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MusicTrack>(
                      initialValue: state.selectedMusic,
                      items: state.musicTracks.map((m) {
                        return DropdownMenuItem<MusicTrack>(
                          value: m,
                          child: Text('${m.name} (${m.bpm} BPM)'),
                        );
                      }).toList(),
                      onChanged: (m) {
                        if (m != null) state.selectMusic(m);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.music_note_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subtitle theme selector
            Text(
              'Dynamic Subtitle Theme',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: SubtitleStyle.values.map((style) {
                final isSel = state.selectedSubtitleStyle == style;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => state.selectSubtitleStyle(style),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xff1c2d27) : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSel ? const Color(0xff1c2d27) : const Color(0xffe5e3dd),
                        ),
                      ),
                      child: Text(
                        style.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 10,
                          color: isSel ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        color: theme.colorScheme.surface,
        child: ElevatedButton(
          onPressed: () {
            context.push('/preview');
          },
          child: const Text('Generate Batch Variations'),
        ),
      ),
    );
  }
}
