import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/domain/engine/cast_generator.dart';
import 'package:tamtam/domain/engine/tamtam_engine.dart';
import 'package:tamtam/domain/models/cast_result.dart';
import 'package:tamtam/domain/models/game_event.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/domain/models/player_state.dart';
import 'package:tamtam/domain/models/rule_profile.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/domain/routes/canonical_routes.dart';

void main() {
  group('Engine Integration', () {
    CastResult r(int value) {
      if (value == 2) return CastResult([Face.black, Face.white, Face.white, Face.white]);
      if (value == 4) return CastResult([Face.black, Face.black, Face.white, Face.white]);
      if (value == 6) return CastResult([Face.white, Face.black, Face.black, Face.black]);
      if (value == 16) return CastResult([Face.white, Face.white, Face.white, Face.white]);
      if (value == 32) return CastResult([Face.black, Face.black, Face.black, Face.black]);
      throw ArgumentError();
    }

    test('Full deterministic Classic match to win', () {
      var state = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Top', seat: Seat.top, kind: PlayerKind.human, progress: 0),
          PlayerState(id: 'p2', name: 'Bottom', seat: Seat.bottom, kind: PlayerKind.human, progress: 0),
        ],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.classic(),
        phase: TurnPhase.waitingForCast,
      );

      final gen = DeterministicCastGenerator([
        r(32), // Top gets 32
        r(2),  // Bottom gets 2
        r(32), // Top gets 32 -> 64
        r(4),  // Bottom gets 4 -> 6
        r(32), // Top gets 32 -> 96
        r(6),  // Bottom gets 6 -> 12
        r(6),  // Top gets 6 -> 102
        r(2),  // Bottom gets 2 -> 14
        r(4),  // Top gets 4 -> 106
        r(4),  // Bottom gets 4 -> 18
        r(4),  // Top gets 4 -> 110 (win)
      ]);

      bool won = false;
      int loops = 0;
      while (!won && loops < 50) {
        loops++;
        if (state.phase == TurnPhase.waitingForCast) {
          final trans = TamTamEngine.apply(state, RequestCast(gen.generate()));
          state = trans.state;
          if (trans.events.any((e) => e is MatchWon)) {
            won = true;
          }
        } else if (state.phase == TurnPhase.turnFinished) {
          final trans = TamTamEngine.apply(state, NextTurn());
          state = trans.state;
        }
      }

      expect(won, isTrue);
      expect(state.winnerId, 'p1');
      expect(state.players[0].progress, 110);
      expect(state.players[1].progress, 18);
    });

    test('Capture chain extra casts', () {
      // Top at 49 (C2). Casts 2 -> 51 (E2). Casts 2 -> 53 (G2).
      final topRoute = CanonicalRoutes.topClassicUnified;
      final bottomRoute = CanonicalRoutes.bottomClassicUnified;
      final rightRoute = CanonicalRoutes.rightClassicUnified;

      final bottomProgress = bottomRoute.indexOf(topRoute[51]);
      final rightProgress = rightRoute.indexOf(topRoute[53]);

      var state = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Top', seat: Seat.top, kind: PlayerKind.human, progress: 49),
          PlayerState(id: 'p2', name: 'Bottom', seat: Seat.bottom, kind: PlayerKind.human, progress: bottomProgress),
          PlayerState(id: 'p3', name: 'Right', seat: Seat.right, kind: PlayerKind.human, progress: rightProgress),
        ],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.classic(),
        phase: TurnPhase.waitingForCast,
      );

      // Top cast 2 -> 51 (E2), capturing Bottom. Gets extra cast.
      // Top cast 2 -> 53 (G2), capturing Right. Gets extra cast.
      final gen = DeterministicCastGenerator([r(2), r(2), r(4)]);

      // 1. Top casts 2
      var t1 = TamTamEngine.apply(state, RequestCast(gen.generate()));
      state = t1.state;
      expect(state.players[0].progress, 51);
      expect(state.players[1].progress, 0); // Bottom captured
      expect(state.extraCastsRemaining, 1);
      
      // transition to next turn (which is extra cast for top)
      state = TamTamEngine.apply(state, NextTurn()).state;
      expect(state.activePlayerIndex, 0);
      expect(state.extraCastsRemaining, 0);

      // 2. Top casts 2 again
      var t2 = TamTamEngine.apply(state, RequestCast(gen.generate()));
      state = t2.state;
      expect(state.players[0].progress, 53);
      expect(state.players[2].progress, 0); // Right captured
      expect(state.extraCastsRemaining, 1);
    });
  });
}
