import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './dashboard_screen.dart';
import '../models/video_configuration.dart';

class BatchPreviewScreen extends ConsumerStatefulWidget {
  const BatchPreviewScreen({super.key});

  @override
  ConsumerState<BatchPreviewScreen> createState() => _BatchPreviewScreenState();
}

class _BatchPreviewScreenState extends ConsumerState<BatchPreviewScreen> {
  int _activeCaptionIndex = 0;
  final List<TextEditingController> _captionControllers = [];

  @override
  void initState() {
    super.initState();
    final state = ref.read(batchProvider);
    for (final caption in state.currentCaptions) {
      _captionControllers.add(TextEditingController(text: caption));
    }
  }

  @override
  void dispose() {
    for (final controller in _captionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCaption(int index, String text) {
    ref.read(batchProvider).updateCaptionAt(index, text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchProvider);
    final subState = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Preview & Edit'),
      ),
      body: Row(
        children: [
          // Left: Vertical mock preview mimicking vertical platform layouts
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mock media layer using Unsplash background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.85,
                      child: Image.network(
                        state.activeMetadata.imageUrls.isNotEmpty
                            ? state.activeMetadata.imageUrls[0]
                            : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Aspect ratio crop borders preview indicator overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.crop, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Active Aspect Ratio: 9:16 (Vertical)',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Watermark preview indicator for free tier users
                  if (!subState.isProUser)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff8c7853),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Watermark Active',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Swipeable captions simulation
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: state.selectedSubtitleStyle == SubtitleStyle.neon
                                  ? const Color(0xff1c2d27)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            state.currentCaptions.isNotEmpty
                                ? state.currentCaptions[_activeCaptionIndex]
                                : 'AuraCut Cinematic Video Engine Ready',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontStyle: state.selectedSubtitleStyle == SubtitleStyle.elegantMinimal
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            state.currentCaptions.length,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeCaptionIndex = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _activeCaptionIndex == index
                                      ? const Color(0xff8c7853)
                                      : Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right: Caption modifier tray
          Expanded(
            flex: 5,
            child: Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Caption Edit',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize each segment of your automated subtitle layers.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.currentCaptions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subtitle Slide ${index + 1}',
                              style: theme.textTheme.labelLarge?.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _captionControllers[index],
                              onChanged: (text) => _updateCaption(index, text),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Batch Setup',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generates 3 ratios (9:16, 1:1, 4:5) concurrently.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: theme.colorScheme.surface,
        child: ElevatedButton(
          onPressed: () {
            // Trigger parallel background execution
            state.startBatchExport(subState.isProUser);
            context.push('/export');
          },
          child: const Text('Export All (Parallel Bulk Run)'),
        ),
      ),
    );
  }
}
