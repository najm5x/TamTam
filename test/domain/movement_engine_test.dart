import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/domain/engine/tamtam_engine.dart';
import 'package:tamtam/domain/models/cast_result.dart';
import 'package:tamtam/domain/models/game_event.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/domain/models/player_state.dart';
import 'package:tamtam/domain/models/rule_profile.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/domain/routes/canonical_routes.dart';

void main() {
  group('Movement Engine Rules', () {
    late GameState classicState;
    late GameState blitzState;

    setUp(() {
      classicState = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Top', seat: Seat.top, kind: PlayerKind.human, progress: 0),
          PlayerState(id: 'p2', name: 'Bottom', seat: Seat.bottom, kind: PlayerKind.human, progress: 0),
        ],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.classic(),
        phase: TurnPhase.waitingForCast,
      );

      blitzState = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Top', seat: Seat.top, kind: PlayerKind.human, progress: 32),
          PlayerState(id: 'p2', name: 'Bottom', seat: Seat.bottom, kind: PlayerKind.human, progress: 32),
        ],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.blitz(),
        phase: TurnPhase.waitingForCast,
      );
    });

    CastResult cast(int value) {
      if (value == 2) return CastResult([Face.black, Face.white, Face.white, Face.white]);
      if (value == 4) return CastResult([Face.black, Face.black, Face.white, Face.white]);
      if (value == 6) return CastResult([Face.white, Face.black, Face.black, Face.black]);
      if (value == 16) return CastResult([Face.white, Face.white, Face.white, Face.white]);
      if (value == 32) return CastResult([Face.black, Face.black, Face.black, Face.black]);
      throw ArgumentError('invalid value');
    }

    test('Continuous first-round crossing', () {
      // Top player is at progress 30. Casts 6. -> target 36
      var state = classicState.copyWith(
        players: [
          classicState.players[0].copyWith(progress: 30),
          classicState.players[1]
        ]
      );
      
      final transition = TamTamEngine.apply(state, RequestCast(cast(6)));
      expect(transition.state.activePlayer.progress, 36);
      expect(transition.events.any((e) => e is BoundaryCrossed && e.cell == 'E1'), isTrue);
      
      final landEvent = transition.events.whereType<PieceLanded>().first;
      expect(landEvent.cell, 'A1'); // Top index 36 is A1
    });

    test('Gate crossing', () {
      // Top player is at progress 60. Casts 2. -> target 62
      var state = classicState.copyWith(
        players: [
          classicState.players[0].copyWith(progress: 60),
          classicState.players[1]
        ]
      );
      
      final transition = TamTamEngine.apply(state, RequestCast(cast(2)));
      expect(transition.state.activePlayer.progress, 62);
      expect(transition.events.any((e) => e is GateCrossed && e.cell == 'H1'), isTrue);
      
      final landEvent = transition.events.whereType<PieceLanded>().first;
      expect(landEvent.cell, 'H2'); // Top index 62 is H2
    });

    test('Finish and Overshoot', () {
      // Top player is at progress 108. Casts 2. -> 110 (win)
      var state = classicState.copyWith(
        players: [
          classicState.players[0].copyWith(progress: 108),
          classicState.players[1]
        ]
      );
      
      final transWin = TamTamEngine.apply(state, RequestCast(cast(2)));
      expect(transWin.state.phase, TurnPhase.matchFinished);
      expect(transWin.state.winnerId, 'p1');
      expect(transWin.state.activePlayer.progress, 110);
      expect(transWin.events.any((e) => e is MatchWon), isTrue);

      // Overshoot: 108 + 4 -> 112
      final transOver = TamTamEngine.apply(state, RequestCast(cast(4)));
      expect(transOver.state.phase, TurnPhase.turnFinished);
      expect(transOver.state.activePlayer.progress, 108); // No movement!
      expect(transOver.events.any((e) => e is OvershootOccurred), isTrue);
      expect(transOver.events.any((e) => e is TurnEnded), isTrue);
    });

    test('Capture mechanics and extra cast', () {
      // Top at 40, Bottom at 42. Top casts 2 -> 42. Captures bottom.
      // Top route at 42: B8. Bottom route at 42: H2. Wait, they don't share the same cell at same progress!
      // Let's place them on the same cell manually.
      // Top casts 2 -> 51. Let's see what cell that is.
      final topRoute = CanonicalRoutes.topClassicUnified;
      final bottomRoute = CanonicalRoutes.bottomClassicUnified;
      final targetCell = topRoute[51];
      final bottomProgress = bottomRoute.indexOf(targetCell);

      var state = classicState.copyWith(
        players: [
          classicState.players[0].copyWith(progress: 49),
          classicState.players[1].copyWith(progress: bottomProgress),
        ]
      );
      
      // Top casts 2 -> 51 -> lands on targetCell.
      final transition = TamTamEngine.apply(state, RequestCast(cast(2)));
      
      expect(transition.state.activePlayer.progress, 51);
      expect(transition.state.players[1].progress, 0); // Bottom reset to 0
      
      expect(transition.events.any((e) => e is PieceCaptured && e.victimId == 'p2'), isTrue);
      expect(transition.events.any((e) => e is ExtraCastGranted), isTrue);
      expect(transition.state.extraCastsRemaining, 1);
      
      // Test Blitz reset
      var bState = blitzState.copyWith(
        players: [
          blitzState.players[0].copyWith(progress: 49),
          blitzState.players[1].copyWith(progress: bottomProgress),
        ]
      );
      final bTrans = TamTamEngine.apply(bState, RequestCast(cast(2)));
      expect(bTrans.state.players[1].progress, 32); // Bottom reset to 32 in Blitz
    });

    test('Home Safety', () {
      // Top at progress 30. Casts 2 -> 32 -> E1. Bottom is at 0 (E1).
      // Since E1 is safe, no capture.
      var state = classicState.copyWith(
        players: [
          classicState.players[0].copyWith(progress: 30),
          classicState.players[1].copyWith(progress: 0),
        ]
      );

      final transition = TamTamEngine.apply(state, RequestCast(cast(2)));
      expect(transition.state.activePlayer.progress, 32);
      expect(transition.state.players[1].progress, 0); // Not captured
      expect(transition.events.any((e) => e is PieceCaptured), isFalse);
      expect(transition.events.any((e) => e is ExtraCastGranted), isFalse);
    });
  });
}
