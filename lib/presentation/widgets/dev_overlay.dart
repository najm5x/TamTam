import 'package:flutter/material.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/cast_result.dart';

class DevOverlay extends StatefulWidget {
  final Widget child;
  final GameState gameState;
  final Function(CastResult)? onForceCast;
  final Function(String, int)? onJumpProgress;

  const DevOverlay({
    super.key,
    required this.child,
    required this.gameState,
    this.onForceCast,
    this.onJumpProgress,
  });

  @override
  State<DevOverlay> createState() => _DevOverlayState();
}

class _DevOverlayState extends State<DevOverlay> {
  bool _expanded = false;
  String? _selectedPlayerId;
  final TextEditingController _progressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.gameState.players.isNotEmpty) {
      _selectedPlayerId = widget.gameState.players.first.id;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: ExpansionPanelList(
                elevation: 0,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _expanded = isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    backgroundColor: Colors.black.withAlpha(200),
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          'DEV MODE | Phase: ${widget.gameState.phase.name} | Active: ${widget.gameState.activePlayerIndex} | Extra: ${widget.gameState.extraCastsRemaining}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      );
                    },
                    body: _buildDevTools(),
                    isExpanded: _expanded,
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevTools() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Force Cast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [2, 4, 6, 16, 32].map((val) {
              return ElevatedButton(
                onPressed: () {
                  if (widget.onForceCast != null) {
                    // Create a dummy cast result that equates to this value
                    // For value 32, it's 4 pieces face up, value is 16*2? Wait, 4 face up = 16, wait, cast results are specific.
                    // Actually the engine just takes value. Let's build a proper cast result.
                    // 2: 3w. 4: 2w. 6: 1w. 16: 4w. 32: 0w.
                    List<Face> faces = [];
                    if (val == 2) { faces = [Face.white, Face.white, Face.white, Face.black]; }
                    else if (val == 4) { faces = [Face.white, Face.white, Face.black, Face.black]; }
                    else if (val == 6) { faces = [Face.white, Face.black, Face.black, Face.black]; }
                    else if (val == 16) { faces = [Face.white, Face.white, Face.white, Face.white]; }
                    else if (val == 32) { faces = [Face.black, Face.black, Face.black, Face.black]; }
                    
                    widget.onForceCast!(CastResult(faces));
                  }
                },
                child: Text('$val'),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Jump Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedPlayerId,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                items: widget.gameState.players.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedPlayerId = val),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _progressController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Progress',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  if (widget.onJumpProgress != null && _selectedPlayerId != null) {
                    final p = int.tryParse(_progressController.text);
                    if (p != null) {
                      widget.onJumpProgress!(_selectedPlayerId!, p);
                    }
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
