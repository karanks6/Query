import 'package:flame/components.dart';
import '../query_game.dart';

abstract class QueryScene extends Component with HasGameReference<QueryGame> {
  Future<void> onEnter() async {}
  Future<void> onExit() async {}
  
  List<String> get activeOverlays => ['flutter_ui'];
}
