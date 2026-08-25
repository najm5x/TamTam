import 'package:flutter/material.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/presentation/skins/board_skin.dart';
import 'package:tamtam/presentation/skins/piece_skin.dart';
import 'package:tamtam/presentation/skins/profile_frame_skin.dart';
import 'package:tamtam/presentation/skins/skin_selection.dart';
import 'package:tamtam/presentation/theme/app_theme.dart';
import 'package:tamtam/presentation/widgets/tamtam_background.dart';
import 'package:tamtam/presentation/widgets/pop_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;

  bool _hapticsEnabled = true;

  // Which of 'board' / 'frame' / 'piece' is currently expanded -- null
  // means all collapsed. Only one selector stays open at a time.
  String? _expandedSkin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18.0,
            letterSpacing: 2.0,
            color: Colors.white,
            shadows: [Shadow(color: Color(0x991B0F2E), blurRadius: 6.0)],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20.0, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: TamTamBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionTitle('AUDIO & HAPTICS'),
              const SizedBox(height: 10.0),
              PopIn(
                order: 0,
                child: _buildSettingsCard(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Sound Effects',
                      value: _soundEnabled,
                      onChanged: (val) => setState(() => _soundEnabled = val),
                    ),
                    const Divider(height: 1.0, indent: 56.0, endIndent: 16.0),
                    _buildSwitchTile(
                      icon: Icons.vibration_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Haptic Feedback',
                      value: _hapticsEnabled,
                      onChanged: (val) => setState(() => _hapticsEnabled = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              PopIn(
                order: 1,
                child: _buildSkinDropdown<BoardSkin>(
                  skinKey: 'board',
                  icon: Icons.grid_view_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  label: 'Board',
                  notifier: SkinSelection.board,
                  options: BoardSkin.all,
                  displayNameOf: (skin) => skin.displayName,
                  previewBuilder: (skin, context) => ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(width: 32.0, height: 32.0, child: skin.backgroundBuilder(context)),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              PopIn(
                order: 2,
                child: _buildSkinDropdown<ProfileFrameSkin>(
                  skinKey: 'frame',
                  icon: Icons.face_retouching_natural_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Frame',
                  notifier: SkinSelection.frame,
                  options: ProfileFrameSkin.all,
                  displayNameOf: (skin) => skin.displayName,
                  previewBuilder: (skin, context) =>
                      SizedBox(width: 32.0, height: 32.0, child: skin.builder(context)),
                ),
              ),
              const SizedBox(height: 12.0),
              PopIn(
                order: 3,
                child: _buildSkinDropdown<PieceSkin>(
                  skinKey: 'piece',
                  icon: Icons.circle_rounded,
                  iconColor: const Color(0xFFF97316),
                  label: 'Piece',
                  notifier: SkinSelection.piece,
                  options: PieceSkin.all,
                  displayNameOf: (skin) => skin.displayName,
                  previewBuilder: (skin, context) =>
                      SizedBox(width: 32.0, height: 32.0, child: skin.builder(context, Seat.bottom)),
                ),
              ),
              const SizedBox(height: 20.0),
              PopIn(
                order: 4,
                child: _buildSettingsCard(
                  children: [
                    _buildActionTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Help',
                      onTap: () => _showHowToPlayModal(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.5,
          shadows: [Shadow(color: Color(0x991B0F2E), blurRadius: 4.0)],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: iconColor, size: 22.0),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 22.0),
          ],
        ),
      ),
    );
  }

  void _showHowToPlayModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'HOW TO PLAY TAMTAM',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryDark,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildRuleStep(
                    number: '1',
                    title: 'Cast 4 Binary Cubes',
                    description:
                        'Each turn, tap to roll four cubes. Black (Pip) is 0, White is 1. All white grants a bonus move + extra turn!',
                  ),
                  _buildRuleStep(
                    number: '2',
                    title: 'Outer Track Journey',
                    description:
                        'Your pawn races counter-clockwise around the outer 9x9 perimeter, crossing quadrants and safe cells.',
                  ),
                  _buildRuleStep(
                    number: '3',
                    title: 'Enter Through Your Gate',
                    description:
                        'Upon completing the outer circuits, pass through your designated gate arrow into the inner sanctuary spiral.',
                  ),
                  _buildRuleStep(
                    number: '4',
                    title: 'Reach Center Sanctuary (E5)',
                    description:
                        'Land exactly on E5 in the middle of the board to claim absolute victory!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('GOT IT!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: const BoxDecoration(
              color: AppTheme.primaryDark,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact collapsible skin selector: tap the header row to expand its
  /// options beneath it; tapping the currently-open one collapses it again.
  /// Only presentation changes here -- SkinSelection notifiers and the
  /// underlying skin catalogs are untouched, so the live gameplay widgets
  /// keep reacting to selection exactly as before.
  Widget _buildSkinDropdown<T>({
    required String skinKey,
    required IconData icon,
    required Color iconColor,
    required String label,
    required ValueNotifier<T> notifier,
    required List<T> options,
    required String Function(T skin) displayNameOf,
    required Widget Function(T skin, BuildContext context) previewBuilder,
  }) {
    final expanded = _expandedSkin == skinKey;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      child: ValueListenableBuilder<T>(
        valueListenable: notifier,
        builder: (context, selected, _) {
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expandedSkin = expanded ? null : skinKey),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(icon, color: iconColor, size: 22.0),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      previewBuilder(selected, context),
                      const SizedBox(width: 6.0),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textSecondary,
                          size: 22.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: !expanded
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 14.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            for (final option in options)
                              ChoiceChip(
                                label: Text(
                                  displayNameOf(option),
                                  style: const TextStyle(fontSize: 11.0),
                                ),
                                selected: selected == option,
                                onSelected: (_) => notifier.value = option,
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required void Function(bool value) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: iconColor, size: 22.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppTheme.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
