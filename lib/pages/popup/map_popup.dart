import 'package:flutter/material.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_helper.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPopup extends StatelessWidget {
  final Function() onYes;
  final String errorText;
  final BuildContext contextLanguage;

  MapPopup(
      {Key key,
      @required this.onYes,
      @required this.errorText,
      @required this.contextLanguage})
      : super(key: key);

  bool isTap = false;
  TextEditingController searchMapController = TextEditingController();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  GoogleMapController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(0.0),
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 0, right: 0, bottom: 16, top: 0),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                            bottomLeft: Radius.circular(44),
                            bottomRight: Radius.circular(44)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16.0,
                            spreadRadius: 1.0,
                            offset: Offset(
                              0.0,
                              8.0,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 44,
                            margin:
                                EdgeInsets.only(top: 16, left: 16, right: 16),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(
                                  top: 0, left: 12, bottom: 0, right: 0),
                              child: TextField(
                                style: AppStyle.style16RegularRed,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 0.0,
                                      right: 0.0,
                                      top: 0.0,
                                      bottom: 3.0),
                                  hintText: 'Enter ZIP Code, State, City...',
                                  hintStyle: AppStyle.style16RegularRed,
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.search,
                                controller: searchMapController,
                                obscureText: false,
                                onChanged: (text) {
                                  //TEXT
                                },
                              ),
                            ),
                          ),

                          //CURRENT LOCATION
                          Container(
                            margin:
                                EdgeInsets.only(left: 16, right: 16, top: 8),
                            height: 56,
                            width: MediaQuery.of(context).size.width - 32,
                            decoration: new BoxDecoration(
                              border: Border.all(
                                  color: AppColor.redColor, width: 1),
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(12)),
                            ),
                            child: FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(12.0)),
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                //CURRENT LOCATION
                              },
                              child: Center(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 8, right: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Image.asset(AppImages.icLocation,
                                          width: 15, height: 20),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 0, right: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text('CURRENT LOCATION',
                                          style: AppStyle.style14BoldRed),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //MAP SCREEN
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 8),
                              width: MediaQuery.of(context).size.width - 32,
                              height: (MediaQuery.of(context).size.width - 32) *
                                  280 /
                                  343,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(28))),
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: const CameraPosition(
                                  target: LatLng(-33.852, 151.211),
                                  zoom: 11.0,
                                ),
                                markers: Set<Marker>.of(markers.values),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //PIC ACTION
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16, bottom: 21),
                      height: 56,
                      width: MediaQuery.of(context).size.width - 32,
                      decoration: new BoxDecoration(
                        color: AppHelper.fromHex('FFC857'),
                        borderRadius: new BorderRadius.all(Radius.circular(28)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(28.0)),
                        padding: EdgeInsets.all(0.0),
                        onPressed: () {
                          //CANCEL
                          Navigator.pop(context);
                        },
                        child: Text(
                          'PICK LOCATION',
                          textAlign: TextAlign.center,
                          style: AppStyle.style14BoldRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }
}
