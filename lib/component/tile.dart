import 'dart:math';
import 'package:hex_place/component/get_texture.dart';
import 'package:hex_place/component/hexagon.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:hex_place/services/settings.dart';
import '../constants/global.dart';
import '../util/util.dart';


class Tile {

  late Vector2 position;
  late int q;
  late int r;
  late int tileType;
  // String? lastChangedBy;
  // DateTime? lastChangedTime;

  // If the map is wrapped around the q will reflect the position accurately
  // But we still save the wrapped Q to show the user and to use it to change.
  // example: the center tile (0, 0) will be saved in tileQ and tileR
  // But q and r might have higher values if the map is wrapped around
  late int tileQ;
  late int tileR;

  double scaleX = 1;

  Hexagon? hexagon;

  // We assume the condition r + s + q = 0 is true.
  Tile(this.q, this.r, this.tileType, this.tileQ, this.tileR) {
    setPosition(Settings().getRotation());
  }

  setHexagon(Hexagon hexagonTile) {
    hexagon = hexagonTile;
  }

  Vector2 getPos() {
    return Vector2(position.x, position.y);
  }

  int getTileType() {
    return tileType;
  }

  setTileType(int tileType) {
    this.tileType = tileType;
  }

  updateTile(SpriteBatch? batches, int rotation) {
    int variant = 0;
    if (rotation == 1 || rotation == 3) {
      variant = 1;
    }
    if (batches != null) {
      batches.add(
          source: tileTextures[tileType][variant],
          offset: getPos(),
          scale: scaleX
      );
    }
  }

  setPosition(rotation) {
    position = getTilePosition(q, r, rotation);
  }

  Tile.fromJson(data) {
    tileType = data["type"];

    q = data['q'];
    r = data['r'];

    tileQ = data["q"];
    tileR = data["r"];

    position = Vector2(0, 0);
  }
}