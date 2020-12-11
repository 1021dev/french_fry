import 'package:bflutter/bflutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/country.dart';
import 'package:french_fry/pages/signup/signup_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = SignUpBloc();
  TextEditingController phoneController = TextEditingController();
  TextEditingController searchCountryController = TextEditingController();
  Country countrySelected;
  int position = 234;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc.getListCountries(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.redColor,
      resizeToAvoidBottomInset: false,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              _buildBody(context),
            ],
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: 45,
        margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: 0, top: 0, bottom: 0),
          width: 50,
          height: 45,
          child: FlatButton(
            padding: EdgeInsets.all(0.0),
            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(12.0),
                  ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              AppImages.icBackWhite,
              width: 9,
              height: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(0),
        decoration: new BoxDecoration(
          color: AppColor.bgColor,
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(44), topRight: Radius.circular(44)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 44)),
              Container(
                height: 34,
                margin: EdgeInsets.only(
                  top: 0,
                ),
                alignment: Alignment.topCenter,
                child: Text(
                  'Sign Up',
                  style: AppStyle.style24MediumRed,
                ),
              ),
              Container(
                height: 56,
                margin: EdgeInsets.only(
                  top: 16,
                ),
                alignment: Alignment.topCenter,
                child: Text(
                  'Please select your country code and\nenter your phone number.',
                  style: AppStyle.style14RegularGrey,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 32)),
              Container(
                height: 148,
                margin: EdgeInsets.only(top: 0, left: 16, right: 16),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppHelper.fromHex('FA8D35').withOpacity(0.5),
                      blurRadius: 35.0,
                      spreadRadius: 1.0,
                      offset: Offset(
                        2.0,
                        2.0,
                      ),
                    )
                  ],
                  borderRadius: new BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  children: <Widget>[
                    _buildCountry(context),
                    _buildLine(context),
                    _buildPhone(context),
                    _buildLine(context),
                  ],
                ),
              ),
              SizedBox(height: AppHelper.getHeightFromScreenSize(context, 32)),
              _buildNext(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountry(BuildContext context) {
    return StreamBuilder(
      stream: bloc.countryBloc.stream,
      builder: (context, AsyncSnapshot<List<Country>> data) {
        return InkWell(
          child: Container(
            margin: EdgeInsets.only(top: 24.5, left: 24, right: 24),
            height: 43,
            child: StreamBuilder(
              stream: bloc.countrySelectedBloc.stream,
              builder: (context, AsyncSnapshot<Country> data) {
                countrySelected = data.data;
                return Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                      padding: EdgeInsets.only(left: 13, right: 13),
                      alignment: Alignment.center,
                      child: Text(data.data?.dialCode ?? '+1',
                          style: AppStyle.style16RegularRed),
                    ),
                    Container(
                      width: 0.5,
                      height: 20,
                      color: Colors.black.withOpacity(0.4),
                      alignment: Alignment.centerLeft,
                    ),
                    Expanded(
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.data?.name ?? 'United States',
                          style: AppStyle.style16RegularGrey,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Container(
                        width: 6,
                        height: 11,
                        alignment: Alignment.centerRight,
                        child: Image.asset(AppImages.icNextRed)),
                  ],
                );
              },
            ),
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
            bloc.searchCountries('');

            showPickerCountry(context, data.data ?? []);

            //OPEN POPUP COUNTRY
            /*
            showDialog(
            context: context,
            builder: (BuildContext context) =>
                searchAndPickYourCountry(context),
            barrierDismissible: true);
            */
          },
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///SHEET COUNTRY
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void showPickerCountry(BuildContext context, List<Country> countries) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              bottom: true,
              top: false,
              child: Container(
                height: 250,
                child: Column(
                  children: <Widget>[
                    _buildLinePicker(),
                    Container(
                      height: 44,
                      color: AppColor.headerColor,
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        child: Text(
                          "Done",
                          style: AppStyle.style15MediumBlue,
                        ),
                        onPressed: () {
                          bloc.countrySelectedBloc.push(countries[position]);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    _buildLinePicker(),
                    Expanded(
                      child: Container(
                        child: CupertinoPicker(
                          scrollController: new FixedExtentScrollController(
                            initialItem: position,
                          ),
                          itemExtent: 35.0,
                          backgroundColor: Colors.white,
                          onSelectedItemChanged: (int index) {
                            position = index;
                          },
                          children: new List<Widget>.generate(
                            countries.length,
                            (int index) {
                              return new Center(
                                child: new Text(
                                  '${countries[index].dialCode}  ${countries[index].name}',
                                  style: AppStyle.style18RegularGrey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildLinePicker() {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
      height: 0.5,
      color: AppColor.lineColor,
    );
  }

  Widget searchAndPickYourCountry(BuildContext context) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Dialog(
          key: Key('SearchCountryDialog'),
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Container(
            margin: const EdgeInsets.all(5.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    searchCountry(searchCountryController),
                    SizedBox(
                      height: 300.0,
                      child: StreamBuilder<List<Country>>(
                          stream: bloc.countryBloc.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data.length == 0
                                  ? Center(
                                      child: Text(
                                          'Your search found no results',
                                          style: TextStyle(fontSize: 16.0)),
                                    )
                                  : ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int i) =>
                                              selectableWidget(
                                                  snapshot.data[i],
                                                  (Country c) =>
                                                      selectThisCountry(c)),
                                    );
                            } else if (snapshot.hasError)
                              return Center(
                                child: Text('Seems, there is an error',
                                    style: TextStyle(fontSize: 16.0)),
                              );
                            return Center(child: CircularProgressIndicator());
                          }),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 0,
                    right: 0,
                  ),
                  height: 25,
                  width: 25,
                  alignment: Alignment.topRight,
                  child: FlatButton(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 19,
                      width: 19,
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  static Widget selectableWidget(
          Country country, Function(Country) selectThisCountry) =>
      Material(
        color: Colors.white,
        type: MaterialType.canvas,
        child: InkWell(
          onTap: () => selectThisCountry(country),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            child: Text(
              "  " +
                  country.flag +
                  "  " +
                  country.name +
                  " (" +
                  country.dialCode +
                  ")",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );

  Widget searchCountry(TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(
            left: 8.0, top: 8.0, bottom: 2.0, right: 25.0),
        child: Card(
          child: TextField(
            autofocus: true,
            controller: controller,
            onChanged: (text) {
              bloc.searchCountries(text);
            },
            decoration: InputDecoration(
                hintText: 'Search your country',
                contentPadding: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
                border: InputBorder.none),
          ),
        ),
      );

  void selectThisCountry(Country country) {
    searchCountryController.clear();
    Navigator.of(context).pop();
    Future.delayed(Duration(milliseconds: 10)).whenComplete(() {
      bloc.countrySelectedBloc.push(country);
    });
  }

  Widget _buildPhone(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.5, left: 24, right: 24),
      height: 43,
      child: StreamBuilder(
        stream: bloc.reloadBLoc.stream,
        builder: (context, data) {
          return TextField(
            style: AppStyle.style16RegularBlack,
            decoration: InputDecoration(
              hintText: 'Your Phone Number',
              hintStyle: AppStyle.style16RegularBlack40,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            controller: phoneController,
            obscureText: false,
            onChanged: (text) {
              var phone = validatePhone(text);
              var cursorPos = phoneController.selection;
              if (phone.length > 19) {
                phoneController.text = phone.substring(0, 19);
              } else {
                phoneController.text = phone;
              }
              cursorPos = new TextSelection.fromPosition(
                  new TextPosition(offset: phoneController.text.length));
              phoneController.selection = cursorPos;

              bloc.checkInput(context, phone);
            },
          );
        },
      ),
    );
  }

  String validatePhone(String phone) {
    if (phone.length == 1 && phone != '(') {
      return '(${phone.toString()}';
    } else if (phone.length == 5 && phone[4] != ")") {
      return '${phone.substring(0, 4).toString()}) ${phone.substring(4).toString()}';
    } else if (phone.length == 10 && phone[9] != "-") {
      return '${phone.substring(0, 9).toString()}-${phone.substring(9).toString()}';
    }
    return '${phone.toString()}';
  }

  Widget _buildLine(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 24, right: 24),
      color: Colors.black.withOpacity(0.4),
      height: 0.5,
    );
  }

  Widget _buildNext(BuildContext context) {
    return StreamBuilder(
      stream: bloc.validInput.stream,
      builder: (context, AsyncSnapshot<bool> data) {
        if (data.data ?? false) {
          return Container(
            width: 168,
            height: 44,
            padding: EdgeInsets.all(0.0),
            alignment: Alignment.topCenter,
            decoration: new BoxDecoration(
              color: AppColor.redColor,
              borderRadius: new BorderRadius.all(Radius.circular(12)),
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
              width: 168,
              height: 44,
              margin: EdgeInsets.all(0.0),
              decoration: new BoxDecoration(
                color: AppColor.redColor,
                borderRadius: new BorderRadius.all(Radius.circular(12)),
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
                  var phone = phoneController.text
                      .replaceAll("(", "")
                      .replaceAll(")", "")
                      .replaceAll(" ", "")
                      .replaceAll("-", "");
                  if (phone.length < 9 || phone.length > 12) {
                    return;
                  }
                  //ACTION
                  bloc.checkPhoneSignUp(
                      context, (countrySelected?.dialCode ?? '+1') + phone);
                },
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                child: Text(
                  'NEXT',
                  style: AppStyle.style14BoldWhite,
                ),
              ),
            ),
          );
        }
        return Opacity(
          opacity: 0.6,
          child: Container(
            width: 168,
            height: 44,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              color: AppColor.redColor,
              borderRadius: new BorderRadius.all(Radius.circular(12)),
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
            child: Text(
              'NEXT',
              style: AppStyle.style14BoldWhite,
            ),
          ),
        );
      },
    );
  }
}
