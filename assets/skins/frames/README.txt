Expected file: custom_frame_01.png
Canvas: 512x512, transparent background
Content: decorative frame art only -- no player name/username baked in
(Flutter renders "Player 1" etc. as text on top of this).

Until this file exists, ProfileFrameSkin.customTest falls back to the
default frame automatically (see profile_frame_skin.dart errorBuilder).
