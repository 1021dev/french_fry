import 'package:bflutter/bflutter.dart';

class CongratulationBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();

  CongratulationBloc() {
    initLogic();
  }

  @override
  void dispose() {
    reloadBloc.dispose();
  }

  @override
  void initLogic() {}
}