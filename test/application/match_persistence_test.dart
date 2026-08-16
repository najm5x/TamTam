import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamtam/application/storage/match_storage.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/domain/models/player_state.dart';
import 'package:tamtam/domain/models/rule_profile.dart';
import 'package:tamtam/domain/models/seat.dart';

void main() {
  group('MatchStorage persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Saves and restores GameState exactly', () async {
      final storage = MatchStorage();
      
      final state = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Alice', seat: Seat.top, kind: PlayerKind.human, progress: 10, isWinner: false),
          PlayerState(id: 'p2', name: 'Bot1', seat: Seat.bottom, kind: PlayerKind.bot, progress: 50, isWinner: true),
        ],
        activePlayerIndex: 1,
        ruleProfile: RuleProfile.blitz(),
        phase: TurnPhase.waitingForCast,
        winnerId: 'p2',
        extraCastsRemaining: 2,
      );

      await storage.saveMatch(state);
      final loaded = await storage.loadMatch();

      expect(loaded, isNotNull);
      expect(loaded!.activePlayerIndex, 1);
      expect(loaded.winnerId, 'p2');
      expect(loaded.extraCastsRemaining, 2);
      expect(loaded.phase, TurnPhase.waitingForCast);
      expect(loaded.ruleProfile.mode, GameMode.blitz);
      
      expect(loaded.players.length, 2);
      expect(loaded.players[0].name, 'Alice');
      expect(loaded.players[0].progress, 10);
      expect(loaded.players[1].kind, PlayerKind.bot);
      expect(loaded.players[1].isWinner, isTrue);
    });

    test('Does not save mid-animation states', () async {
      final storage = MatchStorage();
      
      final state = GameState(
        players: [],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.classic(),
        phase: TurnPhase.animatingMove,
      );

      await storage.saveMatch(state);
      final loaded = await storage.loadMatch();
      expect(loaded, isNull);
    });
  });
}
