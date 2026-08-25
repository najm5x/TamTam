import 'package:flutter/material.dart';
import 'package:tamtam/presentation/theme/app_theme.dart';
import 'package:tamtam/presentation/screens/settings_screen.dart';
import 'package:tamtam/presentation/screens/match_setup_screen.dart';
import 'package:tamtam/presentation/widgets/player_portrait.dart';
import 'package:tamtam/presentation/widgets/pressable_scale.dart';
import 'package:tamtam/presentation/widgets/pop_in.dart';
import 'package:tamtam/presentation/widgets/tamtam_background.dart';
import 'package:tamtam/presentation/widgets/home_sparkle_layer.dart';
import 'package:tamtam/presentation/widgets/home_offers_carousel.dart';
import 'package:tamtam/presentation/navigation/tamtam_page_route.dart';

/// Home is fully art-driven: home_background.png fills the screen and the
/// mode cards are the supplied PNGs (frame/background already baked in) with
/// Flutter-rendered labels on top, per the final product decisions -- no
/// Quick Play, no Blitz card (Blitz stays a rule choice inside match setup).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: TamTamBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: HomeSparkleLayer()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Sizes below are authored in dp against a ~390dp reference
                  // phone width (not the 1080 art canvas, which is a pixel
                  // coordinate space for board/skin geometry, not dp layout)
                  // and scale proportionally from there, clamped so very
                  // narrow/wide screens don't shrink text unreadably or blow
                  // up past intent.
                  final scale = (constraints.maxWidth / 390).clamp(0.85, 1.3).toDouble();
                  const horizontalInset = 20.0;
                  final insetPadding = EdgeInsets.symmetric(horizontal: horizontalInset * scale);
                  // Horizontal inset is applied per-child (not on the
                  // ScrollView) so the banner below can skip it and bleed to
                  // the screen edge -- rendering meaningfully larger than the
                  // old content-width version while keeping its native aspect
                  // ratio; BoxFit.contain still never stretches or crops it.
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        PopIn(
                          order: 0,
                          child: Padding(padding: insetPadding, child: _buildHeader(context, scale)),
                        ),
                        SizedBox(height: 18.0 * scale),
                        PopIn(order: 1, child: _buildOffersBanner()),
                        SizedBox(height: 22.0 * scale),
                        PopIn(
                          order: 2,
                          child: Padding(padding: insetPadding, child: _buildPrimaryRow(context, scale)),
                        ),
                        SizedBox(height: 14.0 * scale),
                        PopIn(
                          order: 3,
                          child: Padding(padding: insetPadding, child: _buildSecondaryRow(context, scale)),
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showProfileDialog(context),
          child: PlayerPortrait(size: 58.0 * scale, accentColor: AppTheme.accentLight),
        ),
        const Spacer(),
        Image.asset(
          'assets/home/tamtam_logo.png',
          height: 62.0 * scale,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        _HeaderImageButton(
          scale: scale,
          asset: 'assets/home/icon_gift.png',
          tooltip: 'Gifts',
          onPressed: () {},
        ),
        SizedBox(width: 8.0 * scale),
        _HeaderImageButton(
          scale: scale,
          asset: 'assets/home/icon_settings.png',
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(context, tamTamRoute((context) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildOffersBanner() {
    return const HomeOffersCarousel();
  }

  Widget _buildPrimaryRow(BuildContext context, double scale) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            asset: 'assets/home/mode_2player.png',
            label: '2 PLAYER',
            labelSize: 17.0 * scale,
            onTap: () => _navigateToMatchSetup(context, '2 Player'),
          ),
        ),
        SizedBox(width: 14.0 * scale),
        Expanded(
          child: _ModeCard(
            asset: 'assets/home/mode_4player.png',
            label: '4 PLAYER',
            labelSize: 17.0 * scale,
            onTap: () => _navigateToMatchSetup(context, '4 Player'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryRow(BuildContext context, double scale) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            asset: 'assets/home/mode_bot.png',
            label: 'PLAY BOT',
            labelSize: 13.0 * scale,
            onTap: () => _navigateToMatchSetup(context, 'Play Bot'),
          ),
        ),
        SizedBox(width: 10.0 * scale),
        Expanded(
          child: _ModeCard(
            asset: 'assets/home/mode_private.png',
            label: 'PRIVATE',
            labelSize: 13.0 * scale,
          ),
        ),
        SizedBox(width: 10.0 * scale),
        Expanded(
          child: _ModeCard(
            asset: 'assets/home/mode_offline.png',
            label: 'OFFLINE',
            labelSize: 13.0 * scale,
          ),
        ),
      ],
    );
  }

  void _navigateToMatchSetup(BuildContext context, String type) {
    Navigator.push(context, tamTamRoute((context) => MatchSetupScreen(gameType: type)));
  }

  void _showProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 20.0),
            const PlayerPortrait(size: 72.0, accentColor: AppTheme.accent),
            const SizedBox(height: 12.0),
            const Text(
              'Player 1',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

class _HeaderImageButton extends StatelessWidget {
  const _HeaderImageButton({
    required this.scale,
    required this.asset,
    required this.tooltip,
    required this.onPressed,
  });

  final double scale;
  final String asset;
  final String tooltip;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onPressed,
        child: Image.asset(asset, width: 40.0 * scale, height: 40.0 * scale),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.asset,
    required this.label,
    required this.labelSize,
    this.onTap,
  });

  final String asset;
  final String label;
  final double labelSize;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
        SizedBox(height: labelSize * 0.4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w900,
            fontFamily: 'Plus Jakarta Sans',
            color: const Color(0xFFFCE9BE),
            letterSpacing: 1.2,
            height: 1.0,
            shadows: const [
              // Tight dark-navy outline-ish core so the ivory reads crisply
              // against any part of the background art...
              Shadow(color: Color(0xFF1B0F2E), blurRadius: 1.0, offset: Offset(-1, 0)),
              Shadow(color: Color(0xFF1B0F2E), blurRadius: 1.0, offset: Offset(1, 0)),
              Shadow(color: Color(0xFF1B0F2E), blurRadius: 1.0, offset: Offset(0, -1)),
              Shadow(color: Color(0xFF1B0F2E), blurRadius: 1.0, offset: Offset(0, 1)),
              // ...plus a soft burgundy drop shadow for depth.
              Shadow(color: Color(0xFF3B0A14), blurRadius: 5.0, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
    if (onTap == null) {
      return Opacity(opacity: 0.85, child: content);
    }
    return PressableScale(onTap: onTap!, child: content);
  }
}
