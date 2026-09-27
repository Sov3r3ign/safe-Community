import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/incident.dart';

class IncidentService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Incident>> getIncidents() async {
    _requireConfigured();
    final rows = await _client
        .from('incidents')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Incident.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Incident> createIncident({
    required String title,
    required String description,
    required String type,
    required String severity,
    required String location,
    required double lat,
    required double lng,
    bool hasMedia = false,
    String? mediaUrl,
  }) async {
    _requireConfigured();
    final user = _client.auth.currentUser;
    if (user == null) throw AuthException('You must sign in before reporting an incident.');
    final profile = await _client.from('profiles').select('name').eq('id', user.id).single();
    final reporterName = (profile['name'] ?? 'Community member') as String;

    final inserted = await _client
        .from('incidents')
        .insert({
          'title': title.trim(),
          'description': description.trim(),
          'type': type,
          'severity': severity,
          'status': 'Pending',
          'location': location,
          'lat': lat,
          'lng': lng,
          'reporter_id': user.id,
          'reporter_name': reporterName,
          'has_media': hasMedia,
          'media_url': mediaUrl,
        })
        .select()
        .single();
    return Incident.fromJson(inserted);
  }

  void _requireConfigured() {
    if (!SupabaseConfig.isConfigured) {
      throw AuthException('Supabase is not configured.');
    }
  }
}
