import 'package:flutter/material.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/player_state.dart';
import '../../domain/models/rule_profile.dart';
import '../../domain/models/seat.dart';
import 'match_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  final String? gameType;

  const MatchSetupScreen({super.key, this.gameType});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  String? _selectedGameType;
  RuleProfile? _selectedProfile;
  String? _botConfig;

  @override
  void initState() {
    super.initState();
    _selectedGameType = widget.gameType;
  }

  void _playGame() {
    if (!_isReadyToPlay()) return;

    final players = <PlayerState>[];
    int startProgress = _selectedProfile!.startProgress;

    if (_selectedGameType == '2 Player') {
      players.add(PlayerState(id: 'p1', name: 'Player 1', seat: Seat.bottom, kind: PlayerKind.human, progress: startProgress));
      players.add(PlayerState(id: 'p2', name: 'Player 2', seat: Seat.top, kind: PlayerKind.human, progress: startProgress));
    } else if (_selectedGameType == '4 Player') {
      players.add(PlayerState(id: 'p1', name: 'Player 1', seat: Seat.bottom, kind: PlayerKind.human, progress: startProgress));
      players.add(PlayerState(id: 'p2', name: 'Player 2', seat: Seat.left, kind: PlayerKind.human, progress: startProgress));
      players.add(PlayerState(id: 'p3', name: 'Player 3', seat: Seat.top, kind: PlayerKind.human, progress: startProgress));
      players.add(PlayerState(id: 'p4', name: 'Player 4', seat: Seat.right, kind: PlayerKind.human, progress: startProgress));
    } else if (_selectedGameType == 'Play Bot') {
      if (_botConfig == '1v1') {
        players.add(PlayerState(id: 'p1', name: 'Player', seat: Seat.bottom, kind: PlayerKind.human, progress: startProgress));
        players.add(PlayerState(id: 'p2', name: 'Bot', seat: Seat.top, kind: PlayerKind.bot, progress: startProgress));
      } else {
        players.add(PlayerState(id: 'p1', name: 'Player', seat: Seat.bottom, kind: PlayerKind.human, progress: startProgress));
        players.add(PlayerState(id: 'p2', name: 'Bot 1', seat: Seat.left, kind: PlayerKind.bot, progress: startProgress));
        players.add(PlayerState(id: 'p3', name: 'Bot 2', seat: Seat.top, kind: PlayerKind.bot, progress: startProgress));
        players.add(PlayerState(id: 'p4', name: 'Bot 3', seat: Seat.right, kind: PlayerKind.bot, progress: startProgress));
      }
    }

    final gameState = GameState(
      players: players,
      ruleProfile: _selectedProfile!,
      activePlayerIndex: 0,
      phase: TurnPhase.waitingForCast,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MatchScreen(initialState: gameState),
      ),
    );
  }

  bool _isReadyToPlay() {
    if (_selectedGameType == null) return false;
    if (_selectedProfile == null) return false;
    if (_selectedGameType == 'Play Bot' && _botConfig == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHOOSE YOUR GAME', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedGameType == null || widget.gameType == null) ...[
                const Text('Game Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTypeCard('2 Player', Icons.people_outline)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeCard('4 Player', Icons.groups)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeCard('Play Bot', Icons.smart_toy)),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (_selectedGameType != null) ...[
                const Text('Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRuleCard(
                        profile: RuleProfile.classic(),
                        title: 'CLASSIC',
                        subtitle: '110 Steps',
                        icon: Icons.hourglass_empty,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRuleCard(
                        profile: RuleProfile.blitz(),
                        title: 'BLITZ',
                        subtitle: '78 Steps',
                        icon: Icons.bolt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (_selectedGameType == 'Play Bot') ...[
                const Text('Opponents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildBotCard('1v1', '1 Opponent')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBotCard('1v3', '3 Opponents')),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _isReadyToPlay()
                      ? const LinearGradient(colors: [Color(0xFFF4A261), Color(0xFFE9C46A)])
                      : LinearGradient(colors: [Colors.grey, Colors.grey]),
                ),
                child: ElevatedButton(
                  onPressed: _isReadyToPlay() ? _playGame : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, IconData icon) {
    final isSelected = _selectedGameType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedGameType = type;
        _selectedProfile = null;
        _botConfig = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A9D8F).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2A9D8F) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF2A9D8F) : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2A9D8F) : Colors.grey.shade800,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required RuleProfile profile,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedProfile?.mode == profile.mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedProfile = profile),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE76F51).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE76F51) : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFFE76F51).withOpacity(0.2), blurRadius: 12, spreadRadius: 2)]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, spreadRadius: 0)],
        ),
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? const Color(0xFFE76F51) : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFE76F51) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE76F51).withOpacity(0.8) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotCard(String config, String label) {
    final isSelected = _botConfig == config;
    return GestureDetector(
      onTap: () => setState(() => _botConfig = config),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF264653).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF264653) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              config,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF264653) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF264653) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
