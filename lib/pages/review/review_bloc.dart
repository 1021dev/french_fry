import 'package:bflutter/bflutter.dart';


class ReviewBloc with AppBloc {
  final mainBloc = MainBloc.instance;
  var reloadBloc = BlocDefault<bool>();


  ReviewBloc() {
    initLogic();
  }

  @override
  void dispose() {
    reloadBloc.dispose();
  }

  @override
  void initLogic() {
    
  }
}