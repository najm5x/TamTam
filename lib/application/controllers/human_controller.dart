import 'dart:async';
import 'player_controller.dart';
import '../../domain/models/cast_result.dart';

class HumanController extends PlayerController {
  final Stream<void> castButtonStream;

  HumanController({
    required super.playerId,
    required super.castGenerator,
    required this.castButtonStream,
  });

  @override
  Future<CastResult> requestCast() async {
    // Wait for the next button press
    await castButtonStream.first;
    return castGenerator.generate();
  }
}
