enum GameMode {
  classic,
  blitz,
}

class RuleProfile {
  final GameMode mode;
  final int startProgress;
  final int finishProgress;
  final Set<String> safeCells;

  const RuleProfile({
    required this.mode,
    required this.startProgress,
    required this.finishProgress,
    required this.safeCells,
  });

  factory RuleProfile.classic() {
    return const RuleProfile(
      mode: GameMode.classic,
      startProgress: 0,
      finishProgress: 110,
      safeCells: {'E1', 'I5', 'E9', 'A5'},
    );
  }

  factory RuleProfile.blitz() {
    return const RuleProfile(
      mode: GameMode.blitz,
      startProgress: 32,
      finishProgress: 110,
      safeCells: {'E1', 'I5', 'E9', 'A5'},
    );
  }
}
