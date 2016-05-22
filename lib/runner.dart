library runner;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

part 'src/Game.dart';
part 'src/Level.dart';
part 'src/Model.dart';
part 'src/Player.dart';
part 'src/View.dart';
part 'src/HighscoreGamekey.dart';

part 'src/blocks/Block.dart';
part 'src/blocks/Ground.dart';
part 'src/blocks/Water.dart';
part 'src/blocks/Trigger.dart';
part 'src/blocks/Bullet.dart';
part 'src/blocks/Finish.dart';
part 'src/blocks/Spawn.dart';
part 'src/blocks/Coin.dart';
part 'src/blocks/Teleport.dart';
part 'src/blocks/Wall.dart';

log(String msg) {
//  if (const String.fromEnvironment('DEBUG') != null) {
    print('debug: $msg');
//  }
}
