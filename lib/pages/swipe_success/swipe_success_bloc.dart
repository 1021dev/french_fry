import 'package:bflutter/bflutter.dart';

class SwipeSuccessBloc with AppBloc {
  final mainBloc = MainBloc.instance;

  SwipeSuccessBloc() {
    initLogic();
  }

  @override
  void dispose() {
  }

  @override
  void initLogic() {}
}