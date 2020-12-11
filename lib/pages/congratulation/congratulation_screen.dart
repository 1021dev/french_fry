import 'package:bflutter/provider/main_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/request/event_request.dart';
import 'package:french_fry/pages/congratulation/congratulation_bloc.dart';
import 'package:french_fry/pages/swipe/swipe_screen.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:french_fry/widgets/transparent_route.dart';
import 'package:qr/qr.dart';

class CongratulationScreen extends StatefulWidget {
  EventRequest eventRequest;
  CongratulationScreen({Key key, @required this.eventRequest }) : super(key: key);

  @override
  _CongratulationScreenState createState() => _CongratulationScreenState();
}

class _CongratulationScreenState extends State<CongratulationScreen> {
  var mainBloc = MainBloc.instance;
  var congratulationBloc = CongratulationBloc();
  TextEditingController firstController = TextEditingController(text: '1');
  TextEditingController secondController = TextEditingController(text: '2');
  TextEditingController thirdController = TextEditingController(text: '3');
  TextEditingController fourController = TextEditingController(text: '4');
  FocusNode focusFirst = FocusNode();
  FocusNode focusSecond = FocusNode();
  FocusNode focusThird = FocusNode();
  FocusNode focusFour = FocusNode();

  @override
  void initState() {
    super.initState();
    firstController.text = widget.eventRequest.codeQR[0];
    secondController.text = widget.eventRequest.codeQR[1];
    thirdController.text = widget.eventRequest.codeQR[2];
    fourController.text = widget.eventRequest.codeQR[3];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: AppHelper.getHeightFromScreenSize(context, 100),
            ),
            Container(
              margin: EdgeInsets.only(top: 0),
              alignment: Alignment.topCenter,
              height: 32,
              child: Text('Congratulations!', style: AppStyle.style24MediumRed),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppHelper.getHeightFromScreenSize(context, 16)),
              alignment: Alignment.center,
              height: 56,
              child: Text(
                'Tell your friends to scan this QR or enter\nthe code to join your session!',
                textAlign: TextAlign.center,
                style: AppStyle.style14RegularGreyHeight,
              ),
            ),
            SizedBox(
              height: AppHelper.getHeightFromScreenSize(context, 48),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 0.0,
              ),
              height: MediaQuery.of(context).size.width <= 667
                  ? 176
                  : AppHelper.getHeightFromScreenSize(context, 176),
              width: MediaQuery.of(context).size.width <= 667
                  ? 176
                  : AppHelper.getHeightFromScreenSize(context, 176),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: ClipRRect(
                child: Center(
                  child: new QrImage(
                    backgroundColor: Colors.white,
                    data: widget.eventRequest.codeQR,
                    size: MediaQuery.of(context).size.width <= 667
                        ? 176
                        : AppHelper.getHeightFromScreenSize(context, 176),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppHelper.getHeightFromScreenSize(context, 48),
            ),
            _buildCodeField(context),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: Container()),
                  SafeArea(
                    top: false,
                    bottom: true,
                    child: _buildButton(context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
      height: 72,
      padding: EdgeInsets.all(0.0),
      alignment: Alignment.bottomCenter,
      decoration: new BoxDecoration(
        color: AppColor.redColor,
        borderRadius: new BorderRadius.all(Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(250, 141, 53, 0.5),
            blurRadius: 16.0,
            spreadRadius: 1.0,
            offset: Offset(
              0.0,
              8.0,
            ),
          ),
        ],
      ),
      child: Container(
        height: 72,
        width: MediaQuery.of(context).size.width - 32,
        margin: EdgeInsets.all(0.0),
        decoration: new BoxDecoration(
          color: AppColor.redColor,
          borderRadius: new BorderRadius.all(Radius.circular(36)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(250, 141, 53, 0.5),
              blurRadius: 16.0,
              spreadRadius: 1.0,
              offset: Offset(
                0.0,
                8.0,
              ),
            ),
          ],
        ),
        child: FlatButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).push(
              CupertinoPageRoute ( //TransparentSlideRoute
                builder: (BuildContext context) => SwipeScreen(eventRequest: widget.eventRequest),
              ),
            );
          },
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(36.0),
          ),
          child: Text(
            'START SWIPING',
            style: AppStyle.style14BoldWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(BuildContext context) {
    return Container(
        height: AppHelper.getWidthFromScreenSize(context, 56),
        alignment: Alignment.topCenter,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(context, firstController, focusFirst),
              _buildTextField(context, secondController, focusSecond),
              _buildTextField(context, thirdController, focusThird),
              _buildTextField(context, fourController, focusFour),
            ],
          ),
        ));
  }

  Widget _buildTextField(
      BuildContext context, TextEditingController controller, FocusNode focus) {
    return Container(
      width: AppHelper.getWidthFromScreenSize(context, 56),
      height: AppHelper.getWidthFromScreenSize(context, 56),
      margin: EdgeInsets.symmetric(
          horizontal: AppHelper.getWidthFromScreenSize(context, 6),
          vertical: 0),
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(Radius.circular(12)),
      ),
      child: TextField(
        // focusNode: focus,
        enabled: false,
        style: AppStyle.style24RegularGrey,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
          hintText: '',
          hintStyle: AppStyle.style24RegularGrey,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        controller: controller,
        obscureText: false,
        onChanged: (text) {},
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
///QR CODE
////////////////////////////////////////////////////////////////////////////////////////////////////////
class QrPainter extends CustomPainter {
  QrPainter(
    String data,
    this.color,
    this.version,
    this.errorCorrectionLevel,
  ) : this._qr = new QrCode(version, errorCorrectionLevel) {
    _p.color = this.color;
    _qr.addData(data);
    _qr.make();
  }

  final QrCode _qr;
  final _p = new Paint()..style = PaintingStyle.fill;

  final int version;
  final int errorCorrectionLevel;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.shortestSide == 0) {
      print(
          "[QR] WARN: width or height is zero. You should set a 'size' value or nest this painter in a Widget that defines a non-zero size");
    }
    final squareSize = size.shortestSide / _qr.moduleCount;
    for (int x = 0; x < _qr.moduleCount; x++) {
      for (int y = 0; y < _qr.moduleCount; y++) {
        if (_qr.isDark(y, x)) {
          final squareRect = new Rect.fromLTWH(
              x * squareSize, y * squareSize, squareSize, squareSize);
          canvas.drawRect(squareRect, _p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is QrPainter) {
      return this.color != oldDelegate.color ||
          this.errorCorrectionLevel != oldDelegate.errorCorrectionLevel ||
          this.version != oldDelegate.version;
    }
    return false;
  }
}

class QrImage extends StatelessWidget {
  QrImage({
    @required String data,
    this.size,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
    Color foregroundColor = const Color(0xFF000000),
    int version = 4,
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
  }) : _painter =
            new QrPainter(data, foregroundColor, version, errorCorrectionLevel);

  final QrPainter _painter;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double size;

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: new Padding(
        padding: this.padding,
        child: new CustomPaint(
          painter: _painter,
        ),
      ),
    );
  }
}
