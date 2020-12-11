
import 'package:french_fry/provider/global.dart' as global;
import 'package:french_fry/my_app.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

void main() async {
  //init dev Global
  global.Global(environment: global.Env.dev());
  await myMain();
}
