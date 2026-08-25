import 'skin_pack.dart';

/// Compile-time local catalog of available skin packs (MVP scope only --
/// no store, backend, or economy).
class SkinCatalog {
  SkinCatalog._();

  static final List<TamTamSkinPack> packs = [
    TamTamSkinPack.tamtam,
    TamTamSkinPack.placeholder,
  ];

  static TamTamSkinPack get defaultPack => packs.first;

  static TamTamSkinPack byId(String id) {
    return packs.firstWhere((p) => p.id == id, orElse: () => defaultPack);
  }
}
