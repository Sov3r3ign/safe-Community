class Incident {
  final String id;
  final String title;
  final String description;
  final String type;
  final String severity;
  final String status;
  final String location;
  final double lat;
  final double lng;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final bool hasMedia;
  final String? mediaUrl;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.status,
    required this.location,
    required this.lat,
    required this.lng,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.hasMedia,
    this.mediaUrl,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: '${json['id']}',
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      type: (json['type'] ?? 'other') as String,
      severity: (json['severity'] ?? 'Low') as String,
      status: (json['status'] ?? 'Pending') as String,
      location: (json['location'] ?? 'Unknown location') as String,
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      reporterId: (json['reporter_id'] ?? '') as String,
      reporterName: (json['reporter_name'] ?? 'Community member') as String,
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      hasMedia: (json['has_media'] ?? false) as bool,
      mediaUrl: json['media_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'title': title,
        'description': description,
        'type': type,
        'severity': severity,
        'status': status,
        'location': location,
        'lat': lat,
        'lng': lng,
        'reporter_id': reporterId,
        'has_media': hasMedia,
        'media_url': mediaUrl,
      };

  Map<String, dynamic> toLegacyMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'severity': severity,
        'status': status,
        'location': location,
        'lat': lat,
        'lng': lng,
        'reporter': reporterName,
        'time': _relativeTime(createdAt),
        'date': createdAt.toLocal().toString().substring(0, 16),
        'hasMedia': hasMedia,
        'mediaUrl': mediaUrl,
      };

  static String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}
