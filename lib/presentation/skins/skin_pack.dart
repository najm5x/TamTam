import 'board_skin.dart';
import 'cast_tray_skin.dart';
import 'dice_skin.dart';
import 'piece_skin.dart';
import 'profile_frame_skin.dart';

/// A complete, matched set of cosmetic skins. All future skins must snap
/// into the fixed slots defined by VisualLayoutContract without per-skin
/// resizing or manual repositioning.
class TamTamSkinPack {
  final String id;
  final String displayName;
  final BoardSkin board;
  final ProfileFrameSkin profileFrame;
  final PieceSkin piece;
  final DiceSkin dice;
  final CastTraySkin castTray;

  TamTamSkinPack({
    required this.id,
    required this.displayName,
    required this.board,
    required this.profileFrame,
    required this.piece,
    required this.dice,
    required this.castTray,
  });

  static final placeholder = TamTamSkinPack(
    id: 'placeholder_pack',
    displayName: 'Placeholder',
    board: BoardSkin.placeholder,
    profileFrame: ProfileFrameSkin.placeholder,
    piece: PieceSkin.placeholder,
    dice: DiceSkin.placeholder,
    castTray: CastTraySkin.placeholder,
  );
}
