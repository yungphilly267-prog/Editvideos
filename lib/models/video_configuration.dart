class VideoTemplate {
  final String id;
  final String name;
  final String description;
  final String retentionMetric;
  final String targetPlatform; // TikTok, Reels, Shorts

  const VideoTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.retentionMetric,
    required this.targetPlatform,
  });
}

class AiVoice {
  final String id;
  final String name;
  final String accent;
  final String samplePath;

  const AiVoice({
    required this.id,
    required this.name,
    required this.accent,
    required this.samplePath,
  });
}

class MusicTrack {
  final String id;
  final String name;
  final int bpm;

  const MusicTrack({
    required this.id,
    required this.name,
    required this.bpm,
  });
}

enum SubtitleStyle {
  clean,
  kinetic,
  neon,
  elegantMinimal,
}

enum VideoAspectRatio {
  vertical9x16,
  square1x1,
  portrait4x5,
}

class VideoConfiguration {
  final VideoTemplate template;
  final AiVoice voice;
  final MusicTrack music;
  final SubtitleStyle subtitleStyle;
  final List<String> batchCaptions;

  VideoConfiguration({
    required this.template,
    required this.voice,
    required this.music,
    required this.subtitleStyle,
    required this.batchCaptions,
  });

  VideoConfiguration copyWith({
    VideoTemplate? template,
    AiVoice? voice,
    MusicTrack? music,
    SubtitleStyle? subtitleStyle,
    List<String>? batchCaptions,
  }) {
    return VideoConfiguration(
      template: template ?? this.template,
      voice: voice ?? this.voice,
      music: music ?? this.music,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      batchCaptions: batchCaptions ?? this.batchCaptions,
    );
  }
}
