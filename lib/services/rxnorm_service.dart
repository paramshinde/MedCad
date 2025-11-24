// lib/services/rxnorm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RxDrug {
  final String name;
  final String rxCui; // normalized RxCUI (if available)
  final String tty;   // term type, optional

  RxDrug({required this.name, required this.rxCui, this.tty = ''});

  @override
  String toString() => '$name (RxCUI: $rxCui)';
}

class RxNormService {
  static const _base = 'https://rxnav.nlm.nih.gov/REST';

  /// Search RxNorm using the prescribable "findRxcuiByString" endpoint (returns rxnorm ids)
  /// Falls back to /drugs?name= if helpful.
  static Future<List<RxDrug>> findByName(String query, {int max = 20}) async {
    if (query.trim().isEmpty) return [];

    final encoded = Uri.encodeQueryComponent(query);
    final uri = Uri.parse('$_base/prescribable/findRxcuiByString.json?name=$encoded');

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        // fallback to /drugs
        return _fallbackDrugs(query, max);
      }
      final Map<String, dynamic> j = jsonDecode(resp.body) as Map<String, dynamic>;
      final idGroup = j['idGroup'] as Map<String, dynamic>?;
      if (idGroup == null) return [];

      final rxnormIds = <String>[];
      if (idGroup['rxnormId'] != null) {
        rxnormIds.addAll(List<String>.from(idGroup['rxnormId']));
      } else if (idGroup['rxnormId'] == null && idGroup['rxnormId'] is String) {
        rxnormIds.add(idGroup['rxnormId'] as String);
      }

      // Convert rxnormIds to readable names by querying rxcui/{id}/properties
      final List<RxDrug> results = [];
      for (var i = 0; i < rxnormIds.length && results.length < max; i++) {
        final id = rxnormIds[i];
        try {
          final propResp = await http.get(Uri.parse('$_base/rxcui/$id/properties.json')).timeout(const Duration(seconds: 6));
          if (propResp.statusCode == 200) {
            final p = jsonDecode(propResp.body) as Map<String, dynamic>;
            final props = p['properties'] as Map<String, dynamic>?;
            final name = props?['name'] as String? ?? query;
            final tty = props?['tty'] as String? ?? '';
            results.add(RxDrug(name: name, rxCui: id, tty: tty));
          }
        } catch (_) {
          // ignore property fetch error for that id
        }
      }

      if (results.isEmpty) {
        return _fallbackDrugs(query, max);
      }
      return results;
    } catch (e) {
      // on network/parsing error, fallback
      return _fallbackDrugs(query, max);
    }
  }

  /// Fallback endpoint - returns 'drugGroup' results from /drugs?name=
  static Future<List<RxDrug>> _fallbackDrugs(String query, int max) async {
    final uri = Uri.parse('$_base/drugs.json?name=${Uri.encodeQueryComponent(query)}');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return [];
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final dg = map['drugGroup'] as Map<String, dynamic>?;
      if (dg == null) return [];
      final concepts = dg['conceptGroup'] as List<dynamic>? ?? [];
      final List<RxDrug> out = [];

      for (var cg in concepts) {
        final members = (cg as Map<String, dynamic>)['conceptProperties'] as List<dynamic>?;
        if (members == null) continue;
        for (var m in members) {
          final mm = m as Map<String, dynamic>;
          final name = mm['name'] as String? ?? '';
          final rxCui = mm['rxcui']?.toString() ?? '';
          if (name.isNotEmpty) out.add(RxDrug(name: name, rxCui: rxCui));
          if (out.length >= max) break;
        }
        if (out.length >= max) break;
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}
