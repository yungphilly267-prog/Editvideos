import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../state/batch_provider.dart';
import '../services/subscription_service.dart';

// Use StateProvider / Provider from Riverpod package
final batchProvider = Provider<BatchProvider>((ref) => BatchProvider());
final subscriptionProvider = Provider<SubscriptionService>((ref) => SubscriptionService());

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleUrlImport() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid product listing URL')),
      );
      return;
    }
    await ref.read(batchProvider).scrapeUrl(url);
  }

  Future<void> _handleFileImport() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final nonNullPaths = result.files.map((f) => f.path).whereType<String>().toList();
        ref.read(batchProvider).importManualPhotos(nonNullPaths);
      }
    } catch (e) {
      ref.read(batchProvider).importManualPhotos([
        'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600',
        'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600'
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchProvider);
    final subState = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    // ListenableBuilders to handle ChangeNotifiers in Provider correctly
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: subState,
          builder: (context, _) {
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Editorial Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AuraCut',
                                style: theme.textTheme.displayMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Video Automation Hub',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.push('/paywall'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: subState.isProUser ? const Color(0xff1c2d27) : const Color(0xff8c7853),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    subState.isProUser ? Icons.verified : Icons.lock_open,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    subState.isProUser 
                                        ? 'PRO' 
                                        : 'FREE: ${state.freeCreditsRemaining} Left',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Dual Import Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import Product Listings',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Paste a Shopify, Etsy, or generic link to scrape description and images, or upload your own photos directly.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  hintText: 'https://your-store.com/products/mug',
                                  suffixIcon: state.isScraping
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(Icons.arrow_forward),
                                          onPressed: _handleUrlImport,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      'OR',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _handleFileImport,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Upload Product Photos (Up to 5)'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  foregroundColor: theme.colorScheme.secondary,
                                  side: const BorderSide(color: Color(0xffe5e3dd)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Scraping Status Panel
                      if (state.isScraping)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Parsing store metadata & high-res assets...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (state.scrapingError != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            state.scrapingError!,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade800),
                          ),
                        ),

                      if (state.activeMetadata.title.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff1c2d27).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xff1c2d27)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Metadata Populated',
                                    style: theme.textTheme.labelLarge?.copyWith(color: const Color(0xff1c2d27)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.activeMetadata.title,
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${state.activeMetadata.price.toStringAsFixed(2)} — ${state.activeMetadata.imageUrls.length} images extracted',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Empty Helper State or Product Preview Panel
                      if (state.activeMetadata.title.isEmpty) ...[
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.insights,
                                  size: 48,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No active storefront link or image batch selected',
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Scandinavian minimalist video pipeline is idle.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      // Recent drafts
                      Text(
                        'Recent Generation Drafts',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.recentDrafts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final draft = state.recentDrafts[index];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                draft.metadata.title,
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Rendered on ${_formatDate(draft.createdAt)} • ${draft.variationsCount} Batch Variations',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xff1c2d27).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  draft.status,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xff1c2d27),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              bottomSheet: state.activeMetadata.title.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      color: theme.colorScheme.surface,
                      child: ElevatedButton(
                        onPressed: () {
                          if (state.freeCreditsRemaining <= 0 && !subState.isProUser) {
                            context.push('/paywall');
                          } else {
                            context.push('/template');
                          }
                        },
                        child: const Text('Next: Select Template'),
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
