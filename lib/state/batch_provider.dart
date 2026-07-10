import 'package:flutter/foundation.dart';
import '../models/product_metadata.dart';
import '../models/video_configuration.dart';
import '../services/scraper_service.dart';
import '../services/video_generator_service.dart';

class BatchDraft {
  final String id;
  final ProductMetadata metadata;
  final DateTime createdAt;
  final int variationsCount;
  final String status; // 'Completed', 'Processing', 'Draft'

  BatchDraft({
    required this.id,
    required this.metadata,
    required this.createdAt,
    required this.variationsCount,
    required this.status,
  });
}

class ThreadProgress {
  final VideoAspectRatio ratio;
  final String label;
  final double progress;
  final String status; // 'Idle', 'Rendering', 'Watermarking', 'Writing to Camera Roll', 'Complete', 'Failed'
  final String? error;

  ThreadProgress({
    required this.ratio,
    required this.label,
    required this.progress,
    required this.status,
    this.error,
  });

  ThreadProgress copyWith({
    VideoAspectRatio? ratio,
    String? label,
    double? progress,
    String? status,
    String? error,
  }) {
    return ThreadProgress(
      ratio: ratio ?? this.ratio,
      label: label ?? this.label,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class BatchProvider extends ChangeNotifier {
  final ScraperService _scraper = ScraperService();
  final VideoGeneratorService _videoGenerator = VideoGeneratorService();

  ProductMetadata _activeMetadata = ProductMetadata.empty();
  ProductMetadata get activeMetadata => _activeMetadata;

  bool _isScraping = false;
  bool get isScraping => _isScraping;

  String? _scrapingError;
  String? get scrapingError => _scrapingError;

  int _freeCreditsRemaining = 3;
  int get freeCreditsRemaining => _freeCreditsRemaining;

  // Selected config fields
  VideoTemplate? _selectedTemplate;
  VideoTemplate? get selectedTemplate => _selectedTemplate;

  AiVoice? _selectedVoice;
  AiVoice? get selectedVoice => _selectedVoice;

  MusicTrack? _selectedMusic;
  MusicTrack? get selectedMusic => _selectedMusic;

  SubtitleStyle _selectedSubtitleStyle = SubtitleStyle.clean;
  SubtitleStyle get selectedSubtitleStyle => _selectedSubtitleStyle;

  final List<String> _currentCaptions = [];
  List<String> get currentCaptions => _currentCaptions;

  // Render variables
  final Map<VideoAspectRatio, ThreadProgress> _exportThreads = {};
  Map<VideoAspectRatio, ThreadProgress> get exportThreads => _exportThreads;

  double get overallProgress {
    if (_exportThreads.isEmpty) return 0.0;
    double sum = 0.0;
    _exportThreads.forEach((key, value) {
      sum += value.progress;
    });
    return sum / _exportThreads.length;
  }

  // Sample templates, voices, and music data
  final List<VideoTemplate> templates = const [
    VideoTemplate(
      id: 'template_problem_solution',
      name: 'Problem/Solution Split Screen',
      description: 'Addresses user paintpoint immediately with vertical splitscreen layout, demonstrating the exact solution.',
      retentionMetric: '88% High Retention',
      targetPlatform: 'TikTok & Reels',
    ),
    VideoTemplate(
      id: 'template_three_reasons',
      name: '3 Reasons to Buy',
      description: 'Numbered, rapid transition hook listing exact utility reasons why buyers choose this product.',
      retentionMetric: '92% Conversion Rate',
      targetPlatform: 'TikTok, Shorts',
    ),
    VideoTemplate(
      id: 'template_flash_sale',
      name: 'Flash Sale Alert',
      description: 'Bold promotional overlay with animated countdown layout, designed specifically for rapid checkout conversion.',
      retentionMetric: '85% Viral Reach',
      targetPlatform: 'Instagram Reels',
    ),
  ];

  final List<AiVoice> voices = const [
    AiVoice(id: 'voice_cara', name: 'Cara', accent: 'US Friendly Narration', samplePath: 'cara.mp3'),
    AiVoice(id: 'voice_marcus', name: 'Marcus', accent: 'UK Professional Sales Voice', samplePath: 'marcus.mp3'),
    AiVoice(id: 'voice_chloe', name: 'Chloe', accent: 'Australian Energetic Creator', samplePath: 'chloe.mp3'),
  ];

  final List<MusicTrack> musicTracks = const [
    MusicTrack(id: 'music_chill', name: 'Nordic Chillout Beat', bpm: 95),
    MusicTrack(id: 'music_viral', name: 'Lo-Fi TikTok Trendsetter', bpm: 120),
    MusicTrack(id: 'music_sales', name: 'High-Impact Upbeat Synth', bpm: 128),
  ];

  final List<BatchDraft> recentDrafts = [
    BatchDraft(
      id: 'draft_1',
      metadata: ProductMetadata(
        title: 'Minimalist Coffee Mug',
        description: 'Perfect mug for slow mornings.',
        price: 24.0,
        imageUrls: ['https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600'],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      variationsCount: 5,
      status: 'Completed',
    ),
    BatchDraft(
      id: 'draft_2',
      metadata: ProductMetadata(
        title: 'Leather Desk Mat',
        description: 'Elegant full-grain leather mat.',
        price: 89.0,
        imageUrls: ['https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600'],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      variationsCount: 3,
      status: 'Completed',
    ),
  ];

  BatchProvider() {
    // Select default configs
    _selectedTemplate = templates[0];
    _selectedVoice = voices[0];
    _selectedMusic = musicTracks[0];
  }

  void selectTemplate(VideoTemplate template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void selectVoice(AiVoice voice) {
    _selectedVoice = voice;
    notifyListeners();
  }

  void selectMusic(MusicTrack track) {
    _selectedMusic = track;
    notifyListeners();
  }

  void selectSubtitleStyle(SubtitleStyle style) {
    _selectedSubtitleStyle = style;
    notifyListeners();
  }

  void updateCaptionAt(int index, String text) {
    if (index >= 0 && index < _currentCaptions.length) {
      _currentCaptions[index] = text;
      notifyListeners();
    }
  }

  void addManualImage(String path) {
    final currentImages = List<String>.from(_activeMetadata.imageUrls);
    currentImages.add(path);
    _activeMetadata = _activeMetadata.copyWith(imageUrls: currentImages);
    notifyListeners();
  }

  void clearActiveWorkspace() {
    _activeMetadata = ProductMetadata.empty();
    _currentCaptions.clear();
    _scrapingError = null;
    _exportThreads.clear();
    notifyListeners();
  }

  Future<void> scrapeUrl(String url) async {
    _isScraping = true;
    _scrapingError = null;
    notifyListeners();

    try {
      final data = await _scraper.scrapeProductUrl(url);
      _activeMetadata = data;
      _isScraping = false;

      // Populate default high-converting promotional text setup captions
      _currentCaptions.clear();
      _currentCaptions.addAll([
        'Meet the all-new ${data.title} ✨',
        'Struggling with low-quality options?',
        'This premium piece changes everything.',
        'Get yours now for only \$${data.price.toStringAsFixed(2)}!',
        'Link in bio to shop now 🛍️',
      ]);

      notifyListeners();
    } catch (e) {
      _isScraping = false;
      _scrapingError = 'Unable to scrape this link. Check the address or upload photos directly.';
      notifyListeners();
    }
  }

  void importManualPhotos(List<String> paths) {
    _activeMetadata = ProductMetadata(
      title: 'My Artisan Product Listing',
      description: 'Handcrafted premium merchandise built with precision materials.',
      price: 49.99,
      imageUrls: paths,
    );

    _currentCaptions.clear();
    _currentCaptions.addAll([
      'Look at this brand new drop! 💎',
      'The ultimate quality upgrade.',
      'Only \$49.99 with free shipping today.',
      'Tap the link in bio to secure yours!',
    ]);

    notifyListeners();
  }

  Future<void> startBatchExport(bool isProUser) async {
    _exportThreads.clear();

    final ratios = [
      VideoAspectRatio.vertical9x16,
      VideoAspectRatio.square1x1,
      VideoAspectRatio.portrait4x5,
    ];

    for (final ratio in ratios) {
      _exportThreads[ratio] = ThreadProgress(
        ratio: ratio,
        label: ratio == VideoAspectRatio.vertical9x16
            ? 'TikTok / Reels Aspect Ratio (9:16)'
            : ratio == VideoAspectRatio.square1x1
                ? 'Instagram Square Aspect Ratio (1:1)'
                : 'Pinterest Portrait Aspect Ratio (4:5)',
        progress: 0.0,
        status: 'Idle',
      );
    }
    notifyListeners();

    // Decrease credits if on Free tier
    if (!isProUser) {
      if (_freeCreditsRemaining > 0) {
        _freeCreditsRemaining--;
      }
    }

    // Run generators concurrently
    final List<Future<void>> renderTasks = [];

    _exportThreads.forEach((ratio, thread) {
      final task = Future(() async {
        _exportThreads[ratio] = thread.copyWith(status: 'Rendering', progress: 0.05);
        notifyListeners();

        try {
          final config = VideoConfiguration(
            template: _selectedTemplate ?? templates[0],
            voice: _selectedVoice ?? voices[0],
            music: _selectedMusic ?? musicTracks[0],
            subtitleStyle: _selectedSubtitleStyle,
            batchCaptions: _currentCaptions,
          );

          await _videoGenerator.generateVideo(
            imagePath: _activeMetadata.imageUrls.isNotEmpty
                ? _activeMetadata.imageUrls[0]
                : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
            configuration: config,
            ratio: ratio,
            captionText: _currentCaptions.join(' '),
            applyWatermark: !isProUser,
            onProgress: (val) {
              final newStatus = val < 0.6
                  ? 'Rendering'
                  : val < 0.9
                      ? 'Watermarking'
                      : 'Writing to Camera Roll';
              _exportThreads[ratio] = thread.copyWith(
                progress: val,
                status: newStatus,
              );
              notifyListeners();
            },
          );

          _exportThreads[ratio] = _exportThreads[ratio]!.copyWith(
            progress: 1.0,
            status: 'Complete',
          );
          notifyListeners();
        } catch (e) {
          _exportThreads[ratio] = _exportThreads[ratio]!.copyWith(
            status: 'Failed',
            error: e.toString(),
          );
          notifyListeners();
        }
      });
      renderTasks.add(task);
    });

    await Future.wait(renderTasks);

    // Save metadata mock to history once completed
    recentDrafts.insert(
      0,
      BatchDraft(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        metadata: _activeMetadata,
        createdAt: DateTime.now(),
        variationsCount: ratios.length,
        status: 'Completed',
      ),
    );
    notifyListeners();
  }
}
