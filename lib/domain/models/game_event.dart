import 'cast_result.dart';

abstract class GameEvent {
  const GameEvent();
}

class CastResolved extends GameEvent {
  final CastResult castResult;
  const CastResolved(this.castResult);
}

class PieceMovementPlanned extends GameEvent {
  final List<String> path;
  const PieceMovementPlanned(this.path);
}

class BoundaryCrossed extends GameEvent {
  final String cell;
  const BoundaryCrossed(this.cell);
}

class GateCrossed extends GameEvent {
  final String cell;
  const GateCrossed(this.cell);
}

class PieceLanded extends GameEvent {
  final String cell;
  const PieceLanded(this.cell);
}

class PieceCaptured extends GameEvent {
  final String victimId;
  final String cell;
  const PieceCaptured(this.victimId, this.cell);
}

class ExtraCastGranted extends GameEvent {
  const ExtraCastGranted();
}

class TurnEnded extends GameEvent {
  final String nextPlayerId;
  const TurnEnded(this.nextPlayerId);
}

class MatchWon extends GameEvent {
  final String winnerId;
  const MatchWon(this.winnerId);
}

class OvershootOccurred extends GameEvent {
  const OvershootOccurred();
}
