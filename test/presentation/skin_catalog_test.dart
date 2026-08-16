import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamtam/domain/models/cast_result.dart';
import 'package:tamtam/domain/models/seat.dart';
import 'package:tamtam/presentation/skins/skin_catalog.dart';

void main() {
  test('SkinCatalog resolves a default placeholder pack', () {
    final pack = SkinCatalog.defaultPack;
    expect(pack.id, isNotEmpty);
    expect(SkinCatalog.byId('does_not_exist'), same(pack));
    expect(SkinCatalog.byId(pack.id), same(pack));
  });

  testWidgets('every placeholder skin builder renders without throwing', (tester) async {
    final pack = SkinCatalog.defaultPack;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Builder(builder: pack.board.backgroundBuilder),
            Builder(builder: pack.profileFrame.builder),
            for (final seat in Seat.values)
              Builder(builder: (context) => pack.piece.builder(context, seat)),
            for (final face in Face.values)
              Builder(builder: (context) => pack.dice.faceBuilder(context, face)),
            Builder(builder: pack.castTray.backgroundBuilder),
          ],
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });
}
