import 'seat.dart';

enum PlayerKind {
  human,
  bot,
}

class PlayerState {
  final String id;
  final String name;
  final Seat seat;
  final PlayerKind kind;
  final int progress;
  final bool isWinner;

  const PlayerState({
    required this.id,
    required this.name,
    required this.seat,
    required this.kind,
    required this.progress,
    this.isWinner = false,
  });

  PlayerState copyWith({
    String? id,
    String? name,
    Seat? seat,
    PlayerKind? kind,
    int? progress,
    bool? isWinner,
  }) {
    return PlayerState(
      id: id ?? this.id,
      name: name ?? this.name,
      seat: seat ?? this.seat,
      kind: kind ?? this.kind,
      progress: progress ?? this.progress,
      isWinner: isWinner ?? this.isWinner,
    );
  }
}
