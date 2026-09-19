import 'package:flame/components.dart';
import '../query_game.dart';

abstract class QueryScene extends Component with HasGameRef<QueryGame> {
  Future<void> onEnter() async {}
  Future<void> onExit() async {}
  
  List<String> get activeOverlays => [];
}
