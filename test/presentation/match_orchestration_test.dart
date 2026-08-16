import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/domain/engine/cast_generator.dart';
import 'package:tamtam/domain/models/cast_result.dart';
import 'package:tamtam/domain/models/game_state.dart';
import 'package:tamtam/domain/models/player_state.dart';
import 'package:tamtam/domain/models/rule_profile.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/presentation/screens/match_screen.dart';
import 'package:tamtam/presentation/screens/result_screen.dart';

void main() {
  group('MatchScreen -> ResultScreen navigation (D1 regression)', () {
    testWidgets('a normal exact-finish win navigates to ResultScreen exactly once', (tester) async {
      // Bot is one cast away from an exact Classic finish (94 + 16 = 110).
      final initialState = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Winner', seat: Seat.bottom, kind: PlayerKind.bot, progress: 94),
          PlayerState(id: 'p2', name: 'Player 2', seat: Seat.top, kind: PlayerKind.human, progress: 0),
        ],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.classic(),
        phase: TurnPhase.waitingForCast,
      );

      final fourWhite = CastResult([Face.white, Face.white, Face.white, Face.white]);
      expect(fourWhite.value, 16);

      await tester.pumpWidget(MaterialApp(
        home: MatchScreen(
          initialState: initialState,
          castGenerator: DeterministicCastGenerator([fourWhite]),
        ),
      ));

      // Drain the bot-cast delay, cube toss, pause, and the 16-cell movement
      // animation (16 * 75ms), plus the post-movement pre-navigation delay.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400));
      for (var i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 75));
      }
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50)); // page transition
      }

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.byType(MatchScreen), findsNothing);
      expect(find.text('Winner'), findsOneWidget);
    });
  });

  group('ResultScreen REMATCH (D2 regression)', () {
    testWidgets('produces a fresh match instead of resuming stale winner state', (tester) async {
      final finishedState = GameState(
        players: [
          PlayerState(id: 'p1', name: 'Winner', seat: Seat.bottom, kind: PlayerKind.human, progress: 110, isWinner: true),
          PlayerState(id: 'p2', name: 'Player 2', seat: Seat.top, kind: PlayerKind.human, progress: 47),
        ],
        activePlayerIndex: 0,
        ruleProfile: RuleProfile.classic(),
        phase: TurnPhase.matchFinished,
        winnerId: 'p1',
      );

      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          winnerName: 'Winner',
          winnerColor: Colors.orange,
          finishedState: finishedState,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 900)); // entrance animation

      await tester.tap(find.text('REMATCH'));
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50)); // page transition
      }

      expect(find.byType(ResultScreen), findsNothing);
      expect(find.byType(MatchScreen), findsOneWidget);

      final freshState = tester.widget<MatchScreen>(find.byType(MatchScreen)).initialState!;

      expect(freshState.phase, TurnPhase.waitingForCast);
      expect(freshState.winnerId, isNull);
      expect(freshState.extraCastsRemaining, 0);
      expect(freshState.activePlayerIndex, 0);
      for (final p in freshState.players) {
        expect(p.progress, freshState.ruleProfile.startProgress);
        expect(p.isWinner, isFalse);
      }
      // Same seats/kinds/ids preserved.
      expect(freshState.players.map((p) => p.id), finishedState.players.map((p) => p.id));
      expect(freshState.players.map((p) => p.seat), finishedState.players.map((p) => p.seat));
      expect(freshState.players.map((p) => p.kind), finishedState.players.map((p) => p.kind));
    });
  });
}
