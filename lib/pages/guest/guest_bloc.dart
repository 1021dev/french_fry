import 'package:bflutter/bflutter.dart';

class GuestBloc with AppBloc {
  final mainBloc = MainBloc.instance;

  GuestBloc() {
    initLogic();
  }

  @override
  void dispose() {
  }

  @override
  void initLogic() {}
}