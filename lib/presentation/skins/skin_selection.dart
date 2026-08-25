import 'package:flutter/foundation.dart';
import 'board_skin.dart';
import 'piece_skin.dart';
import 'profile_frame_skin.dart';

/// In-memory selection of which skin is active per cosmetic slot, chosen
/// independently. No persistence, no backend, no unlock system -- exists
/// only to prove board/frame/piece skins are interchangeable. Resets on
/// app restart.
class SkinSelection {
  SkinSelection._();

  static final ValueNotifier<BoardSkin> board = ValueNotifier(BoardSkin.tamtam);
  static final ValueNotifier<ProfileFrameSkin> frame = ValueNotifier(ProfileFrameSkin.tamtam);
  static final ValueNotifier<PieceSkin> piece = ValueNotifier(PieceSkin.tamtam);
}
