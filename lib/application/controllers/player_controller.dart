import 'dart:async';
import '../../domain/engine/cast_generator.dart';
import '../../domain/models/cast_result.dart';

abstract class PlayerController {
  final String playerId;
  final CastGenerator castGenerator;

  PlayerController({
    required this.playerId,
    required this.castGenerator,
  });

  /// Request a cast. Bots will naturally delay, humans will wait for button press.
  Future<CastResult> requestCast();
}
