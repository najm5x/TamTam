import 'dart:math';
import '../models/cast_result.dart';

abstract class CastGenerator {
  CastResult generate();
}

class FairBinaryCastGenerator implements CastGenerator {
  final Random _random;

  FairBinaryCastGenerator([Random? random]) : _random = random ?? Random();

  @override
  CastResult generate() {
    final faces = List.generate(4, (_) {
      return _random.nextBool() ? Face.white : Face.black;
    });
    return CastResult(faces);
  }
}

class DeterministicCastGenerator implements CastGenerator {
  final List<CastResult> _sequence;
  int _index = 0;

  DeterministicCastGenerator(this._sequence);

  @override
  CastResult generate() {
    if (_sequence.isEmpty) throw StateError('No cast results available');
    final res = _sequence[_index];
    _index = (_index + 1) % _sequence.length;
    return res;
  }
}
