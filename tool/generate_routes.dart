// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final jsonFile = File('assets/routes/04_Canonical_Routes.json');
  if (!jsonFile.existsSync()) {
    print('Error: JSON file not found at ${jsonFile.path}');
    exit(1);
  }

  final jsonStr = jsonFile.readAsStringSync();
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final players = data['players'] as Map<String, dynamic>;

  final StringBuffer out = StringBuffer();

  out.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  out.writeln('// Generated from 04_Canonical_Routes.json');
  out.writeln();
  out.writeln('class CanonicalRoutes {');

  for (final entry in players.entries) {
    final playerStr = entry.key; // top, right, bottom, left
    final pData = entry.value as Map<String, dynamic>;

    final String home = pData['home'];
    final String gate = pData['gate'];
    final String firstInwardCell = pData['first_inward_cell'];
    final String preFinish = pData['pre_finish'];
    final String finish = pData['finish'];
    
    final List<dynamic> firstRound = pData['first_round'];
    final List<dynamic> secondRound = pData['second_round'];
    final List<dynamic> classicUnified = pData['classic_unified'];

    out.writeln('  // ${playerStr.toUpperCase()} Player');
    out.writeln('  static const String ${playerStr}Home = \'$home\';');
    out.writeln('  static const String ${playerStr}Gate = \'$gate\';');
    out.writeln('  static const String ${playerStr}FirstInwardCell = \'$firstInwardCell\';');
    out.writeln('  static const String ${playerStr}PreFinish = \'$preFinish\';');
    out.writeln('  static const String ${playerStr}Finish = \'$finish\';');
    out.writeln();
    out.writeln('  static const List<String> ${playerStr}FirstRound = [');
    for (final c in firstRound) {
      out.writeln('    \'$c\',');
    }
    out.writeln('  ];');
    out.writeln();
    out.writeln('  static const List<String> ${playerStr}SecondRound = [');
    for (final c in secondRound) {
      out.writeln('    \'$c\',');
    }
    out.writeln('  ];');
    out.writeln();
    out.writeln('  static const List<String> ${playerStr}ClassicUnified = [');
    for (final c in classicUnified) {
      out.writeln('    \'$c\',');
    }
    out.writeln('  ];');
    out.writeln();
  }

  out.writeln('}');

  final outDir = Directory('lib/domain/routes');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final outFile = File('lib/domain/routes/canonical_routes.dart');
  outFile.writeAsStringSync(out.toString());
  print('Successfully generated \${outFile.path}');
}
