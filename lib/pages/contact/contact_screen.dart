import 'package:bflutter/bflutter.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:french_fry/models/remote/contact_model.dart';
import 'package:french_fry/pages/contact/contact_bloc.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:french_fry/utils/debouncer.dart';

class ContactScreen extends StatefulWidget {
  ContactScreen({Key key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final mainBloc = MainBloc.instance;
  final bloc = ContactBloc();
  TextEditingController peopleController = TextEditingController();
  final Debouncer onSearchDebouncer =
      new Debouncer(delay: new Duration(milliseconds: 500));
  ScrollController _scrollcontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    bloc.getAllContact(context);
    bloc.createEventBloc.push(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.redColor,
      resizeToAvoidBottomInset: false,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: GestureDetector(
          child: StreamBuilder(
            stream: bloc.loading.stream,
            builder: (context, AsyncSnapshot<bool> data) {
              return Container(
                margin: EdgeInsets.only(top: 0, left: 0, bottom: 0),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        _buildHeaderPeople(context),
                        _buildBodyAddPeople(context),
                      ],
                    ),
                    AppHelper.buildLoading(data.data ?? false),
                  ],
                ),
              );
            },
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderPeople(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: 56,
        margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 0, top: 0, bottom: 0),
              width: 50,
              height: 56,
              child: FlatButton(
                padding: EdgeInsets.all(0.0),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                },
                child: Image.asset(AppImages.icBackWhite, width: 9, height: 16),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: bloc.searchContactBloc.stream,
                builder: (context, AsyncSnapshot<String> dataSearch) {
                  return Container(
                    height: 40,
                    margin: EdgeInsets.only(left: 0, right: 16),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            style: AppStyle.style14RegularWhite,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 12.0,
                                  right: 12.0,
                                  top: 0.0,
                                  bottom: 7.0),
                              hintText: 'Search People from Your Contacts',
                              hintStyle: AppStyle.style14RegularWhite,
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            controller: peopleController,
                            obscureText: false,
                            onChanged: (text) {
                              bloc.searchContactBloc.push(text);
                              if (text == '') {
                                bloc.searchContactWithKey(text);
                              }
                              this.onSearchDebouncer.debounce(
                                () {
                                  bloc.searchContactWithKey(text);
                                },
                              );
                            },
                            onSubmitted: (text) {
                              FocusScope.of(context).unfocus();
                              bloc.searchContactWithKey(text);
                            },
                          ),
                        ),
                        (dataSearch.data ?? '').length > 0
                            ? Container(
                                width: 40,
                                margin: EdgeInsets.only(
                                    top: 0, bottom: 0, right: 0),
                                child: FlatButton(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(0.0),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      peopleController.text = "";
                                      bloc.searchContactBloc.push('');
                                      bloc.searchContactWithKey('');
                                    },
                                    child: Image.asset(AppImages.icClear,
                                        width: 16, height: 16)))
                            : Container()
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////////////////
  ///ADD PEOPLE
  ///////////////////////////////////////////////////////////////////////

  Widget _buildBodyAddPeople(BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 0, left: 0, bottom: 0, right: 0),
            decoration: new BoxDecoration(
                color: AppColor.bgColor,
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36))),
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36), topRight: Radius.circular(36)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder(
                      stream: bloc.listContactBloc.stream,
                      builder:
                          (context, AsyncSnapshot<List<ContactModel>> data) {
                        return Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(
                              top: 0, bottom: 0, left: 16, right: 0),
                          child: (data.data ?? []).length > 0
                              ? ListView.builder(
                                  controller: _scrollcontroller,
                                  padding: EdgeInsets.only(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom +
                                          32 +
                                          56),
                                  itemCount: (data.data ?? []).length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _buildItemContact(context,
                                        (data.data ?? [])[index], index);
                                  },
                                )
                              : Container(),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 40,
                    margin: EdgeInsets.only(
                        right: 0,
                        top: AppHelper.getHeightFromScreenSize(
                            context,
                            MediaQuery.of(context).size.height <= 667
                                ? 40
                                : 48)),
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: (bloc.listAlpha).length,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return _buildAlphaItem(
                              context, (bloc.listAlpha)[index], index);
                        }),
                    /*child: Text(
                      'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ\n\#',
                      textAlign: TextAlign.center,
                      style: MediaQuery.of(context).size.height <= 667
                          ? TextStyle(
                              fontSize: 14.0,
                              height: 1.3,
                              fontFamily: AppFonts.Poppins,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400,
                              color: AppHelper.fromHex('#4C0148'))
                          : TextStyle(
                              fontSize: 16.0,
                              height: 1.25,
                              fontFamily: AppFonts.Poppins,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400,
                              color: AppHelper.fromHex('#4C0148')),
                    ),*/
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Container(
              margin: EdgeInsets.only(left: 0, bottom: 0, right: 0),
              alignment: Alignment.bottomCenter,
              child: _buildCreateEventButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphaItem(BuildContext context, String item, int index) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
      height: MediaQuery.of(context).size.height <= 667 ? 19.3 : 20.3,
      alignment: Alignment.center,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        child: Text(
          item,
          style: MediaQuery.of(context).size.height <= 667
              ? TextStyle(
                  fontSize: 14.0,
                  fontFamily: AppFonts.Poppins,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: AppHelper.fromHex('#4C0148'))
              : TextStyle(
                  fontSize: 15.5,
                  fontFamily: AppFonts.Poppins,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: AppHelper.fromHex('#4C0148'),
                ),
        ),
        onPressed: () {
          scrollToItem(context, item);
        },
      ),
    );
  }

  void scrollToItem(BuildContext context, String keyItem) {
    double offset = 0;
    bool isHave = false;
    for (var item in bloc.listSearchContacts) {
      if (item.key == keyItem) {
        isHave = true;
        break;
      } else {
        offset += 42.0 + 60.0 * item.listContact.length;
      }
    }
    if (isHave) {
      _scrollcontroller.animateTo(offset,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut,);
    }
  }

  Widget _buildCreateEventButton(BuildContext context) {
    return StreamBuilder(
      stream: bloc.createEventBloc.stream,
      builder: (context, AsyncSnapshot<bool> data) {
        // if (data.data ?? false) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
          height: 56,
          padding: EdgeInsets.all(0.0),
          alignment: Alignment.bottomCenter,
          decoration: new BoxDecoration(
            color: AppColor.redColor,
            borderRadius: new BorderRadius.all(Radius.circular(28)),
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
            height: 56,
            width: MediaQuery.of(context).size.width - 32,
            margin: EdgeInsets.all(0.0),
            decoration: new BoxDecoration(
              color: AppColor.redColor,
              borderRadius: new BorderRadius.all(Radius.circular(28)),
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
                //ADD CONTACT
                bloc.addContact(context);
              },
              padding: EdgeInsets.all(0.0),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(28.0),
              ),
              child: Text(
                'INVITE GUESTS',
                style: AppStyle.style14BoldWhite,
              ),
            ),
          ),
        );
        /*} 
        return Opacity(
          opacity: 0.6,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
            height: 56,
            width: MediaQuery.of(context).size.width - 32,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              color: AppColor.redColor,
              borderRadius: new BorderRadius.all(Radius.circular(28)),
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
              'INVITE GUESTS',
              style: AppStyle.style14BoldWhite,
            ),
          ),
        );*/
      },
    );
  }

  Widget _buildItemContact(BuildContext context, ContactModel item, int index) {
    return Column(
      children: <Widget>[
        Container(
          height: 42,
          margin: EdgeInsets.only(top: 0, left: 0, right: 0),
          child: Container(
            margin: EdgeInsets.only(top: 18, left: 8, right: 0),
            alignment: Alignment.topLeft,
            height: 24,
            child: Text(
              item.key,
              style: AppStyle.style16RegularGrey,
            ),
          ),
        ),
        Container(
          height: 60.0 * item.listContact.length,
          margin: EdgeInsets.all(0.0),
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: (item.listContact).length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItemContactChild(
                    context, (item.listContact)[index], index);
              }),
        )
      ],
    );
  }

  Widget _buildItemContactChild(BuildContext context, Contact item, int index) {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 0, left: 0, right: 0),
      child: Container(
        height: 52,
        margin: EdgeInsets.only(top: 8, left: 0, right: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: FlatButton(
          padding: EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(12.0)),
          child: Row(
            children: <Widget>[
              //AVATAR
              /* CUTOMER REQUIRED
              Container(
                height: 36,
                width: 36,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(
                  left: 12,
                ),
                decoration: BoxDecoration(
                    color: AppHelper.fromHex('C6C6C6'), shape: BoxShape.circle),
              ),*/

              //USER PHONE NAME
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 12, right: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(item.displayName ?? '',
                      style: AppStyle.style16RegularGrey),
                ),
              ),

              //CHECK
              Container(
                height: 24,
                width: 24,
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  right: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: item.jobTitle == "1"
                          ? AppColor.redColor
                          : AppColor.bgColor),
                  color: item.jobTitle == "1"
                      ? AppColor.redColor
                      : AppColor.bgColor.withOpacity(0.6),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: item.jobTitle == "1"
                    ? Image.asset(AppImages.icCheckWhite,
                        width: 29 / 2, height: 21 / 2)
                    : Container(),
              ),
            ],
          ),
          onPressed: () {
            bloc.selectedContactItem(item);
          },
        ),
      ),
    );
  }
}
