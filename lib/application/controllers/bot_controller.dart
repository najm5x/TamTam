import 'dart:async';
import 'player_controller.dart';
import '../../domain/models/cast_result.dart';

class BotController extends PlayerController {
  final Duration delay;

  BotController({
    required super.playerId,
    required super.castGenerator,
    this.delay = const Duration(milliseconds: 600),
  });

  @override
  Future<CastResult> requestCast() async {
    // Natural delay before casting
    await Future.delayed(delay);
    return castGenerator.generate();
  }
}
