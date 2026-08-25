Expected file: custom_piece_01.png
Canvas: 512x512, transparent background
Content: a single piece, logical anchor = image center. Displayed at
~68% of the board cell size; do not bake in seat/player color if it
should still read correctly across all four seats.

Until this file exists, PieceSkin.customTest falls back to the default
piece automatically (see piece_skin.dart errorBuilder).
