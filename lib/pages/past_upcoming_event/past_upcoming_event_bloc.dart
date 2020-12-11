import 'package:bflutter/bflutter.dart';

class PastUpcommingEventBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();

  PastUpcommingEventBloc() {
    initLogic();
  }

  @override
  void dispose() {
    reloadBloc.dispose();
  }

  @override
  void initLogic() {}
}