import 'package:bflutter/bflutter.dart';

class EventDetailBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();
  var loading = BlocDefault<bool>();

  EventDetailBloc() {
    initLogic();
  }

  @override
  void dispose() {
    reloadBloc.dispose();
  }

  @override
  void initLogic() {}
}