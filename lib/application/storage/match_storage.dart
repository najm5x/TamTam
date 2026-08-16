// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/rule_profile.dart';
import '../../domain/models/seat.dart';

class MatchStorage {
  static const String _key = 'tamtam_saved_match';

  Future<void> saveMatch(GameState state) async {
    // Only save if we are in a stable waiting state or match finished.
    if (state.phase == TurnPhase.animatingMove) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_gameStateToJson(state));
    await prefs.setString(_key, jsonStr);
  }

  Future<GameState?> loadMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;

    try {
      final map = jsonDecode(jsonStr);
      return _gameStateFromJson(map);
    } catch (e) {
      print('Error loading match: $e');
      return null;
    }
  }

  Future<void> clearMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Map<String, dynamic> _gameStateToJson(GameState state) {
    return {
      'players': state.players.map((p) => _playerStateToJson(p)).toList(),
      'activePlayerIndex': state.activePlayerIndex,
      'ruleProfile': _ruleProfileToJson(state.ruleProfile),
      'phase': state.phase.name,
      'winnerId': state.winnerId,
      'extraCastsRemaining': state.extraCastsRemaining,
    };
  }

  GameState _gameStateFromJson(Map<String, dynamic> json) {
    return GameState(
      players: (json['players'] as List).map((p) => _playerStateFromJson(p)).toList(),
      activePlayerIndex: json['activePlayerIndex'],
      ruleProfile: _ruleProfileFromJson(json['ruleProfile']),
      phase: TurnPhase.values.firstWhere((e) => e.name == json['phase']),
      winnerId: json['winnerId'],
      extraCastsRemaining: json['extraCastsRemaining'] ?? 0,
    );
  }

  Map<String, dynamic> _playerStateToJson(PlayerState p) {
    return {
      'id': p.id,
      'name': p.name,
      'seat': p.seat.name,
      'kind': p.kind.name,
      'progress': p.progress,
      'isWinner': p.isWinner,
    };
  }

  PlayerState _playerStateFromJson(Map<String, dynamic> json) {
    return PlayerState(
      id: json['id'],
      name: json['name'],
      seat: Seat.values.firstWhere((e) => e.name == json['seat']),
      kind: PlayerKind.values.firstWhere((e) => e.name == json['kind']),
      progress: json['progress'],
      isWinner: json['isWinner'] ?? false,
    );
  }

  Map<String, dynamic> _ruleProfileToJson(RuleProfile r) {
    return {
      'mode': r.mode.name,
      'startProgress': r.startProgress,
      'finishProgress': r.finishProgress,
      'safeCells': r.safeCells.toList(),
    };
  }

  RuleProfile _ruleProfileFromJson(Map<String, dynamic> json) {
    return RuleProfile(
      mode: GameMode.values.firstWhere((e) => e.name == json['mode']),
      startProgress: json['startProgress'],
      finishProgress: json['finishProgress'],
      safeCells: Set<String>.from(json['safeCells']),
    );
  }
}
