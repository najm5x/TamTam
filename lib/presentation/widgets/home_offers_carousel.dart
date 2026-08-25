import 'dart:async';

import 'package:flutter/material.dart';

/// Auto-advancing Home offers carousel: three full-bleed banner images with
/// a manual-swipe PageView plus a periodic timer that keeps rotating
/// regardless of user interaction (per product decision: auto-rotation
/// never permanently stops after a manual swipe).
class HomeOffersCarousel extends StatefulWidget {
  const HomeOffersCarousel({super.key});

  static const List<String> _banners = [
    'assets/home/offers_banner.png',
    'assets/home/offers_banner1.png',
    'assets/home/offers_banner2.png',
  ];

  // offers_banner.png (1536x1024) is the tallest of the three source
  // images -- the carousel viewport uses its ratio so every banner fits by
  // width via BoxFit.contain without ever being cropped or squashed; the
  // wider banners (offers_banner1/2, 1672x941) simply letterbox within it.
  static const double _viewportAspectRatio = 1536 / 1024;

  @override
  State<HomeOffersCarousel> createState() => _HomeOffersCarouselState();
}

class _HomeOffersCarouselState extends State<HomeOffersCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _advance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (!_controller.hasClients) {
      return;
    }
    final next = (_page + 1) % HomeOffersCarousel._banners.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
        AspectRatio(
          aspectRatio: HomeOffersCarousel._viewportAspectRatio,
          child: PageView.builder(
            controller: _controller,
            itemCount: HomeOffersCarousel._banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Image.asset(
              HomeOffersCarousel._banners[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(HomeOffersCarousel._banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              width: active ? 8.0 : 6.0,
              height: active ? 8.0 : 6.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? const Color(0xFFFCE9BE).withValues(alpha: 0.95)
                    : const Color(0xFFFCE9BE).withValues(alpha: 0.35),
              ),
            );
          }),
        ),
        ],
      ),
    );
  }
}
