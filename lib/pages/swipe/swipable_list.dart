import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:french_fry/models/remote/restaurant_model.dart';
import 'package:french_fry/pages/swipe/backdrop.dart';
import 'package:french_fry/test_swipe.dart';
import 'package:french_fry/utils/app_asset.dart';
import 'package:french_fry/utils/app_color.dart';
import 'package:french_fry/utils/app_style.dart';
import 'package:rxdart/subjects.dart';
import 'dart:math' as math;
import 'package:supercharged/supercharged.dart';

import 'package:smooth_star_rating/smooth_star_rating.dart';

class SwipeableList extends StatefulWidget {
  final BehaviorSubject<List<dynamic>> items;
  final bool isPhoto;
  final Function onImageTab;
  final Function(SwipeDirection, int) onSwipe;
  final BehaviorSubject<SwipeDirection> swipe;
  final double fullWidth;
  final double fullHeight;
  final Stream stream;
  SwipeableList(
      {Key key,
      @required this.fullHeight,
      @required this.fullWidth,
      @required this.isPhoto,
      @required this.onImageTab,
      @required this.items,
      @required this.onSwipe,
      @required this.stream,
      @required this.swipe})
      : super(key: key);

  @override
  _SwipeableListState createState() => _SwipeableListState();
}

const _kFlingVelocity = 2.0;

class _SwipeableListState extends State<SwipeableList> with TickerProviderStateMixin {
  AnimationController horizontalAnimationController;
  AnimationController iconsAnimationController;

  SequenceAnimation horizontalAnimation;
  SequenceAnimation iconsAnimation;

  AnimationController verticalAnimationController;
  //
  BoxConstraints frontWidgetConstrains;
  double backWidgetFullHeight;

  SequenceAnimation verticalAnimation;
  ValueNotifier<String> swipeDirection = ValueNotifier('left');
  ValueNotifier horizontalDragOffset = ValueNotifier(Offset(0, 0));

  ValueNotifier<double> _dragExtent = ValueNotifier(0);
  ValueNotifier<bool> _dragUnderway = ValueNotifier(false);
  // Init State.
  @override
  void initState() {
    widget.items.listen((event) {
      setState(() {});
    });
    frontWidgetConstrains = BoxConstraints(
        minHeight: (widget.fullHeight * (widget.fullHeight > 700 ? 0.157 : 0.14)),
        minWidth: widget.fullWidth * .808,
        maxWidth: widget.fullWidth * .914,
        maxHeight: widget.fullHeight * (widget.fullHeight > 700 ? .7 : .68));
    backWidgetFullHeight = widget.fullHeight * (widget.fullHeight > 700 ? .65 : .6);

    horizontalAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    iconsAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    verticalAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    iconsAnimation = SequenceAnimationBuilder()
        .addAnimatable(
            curve: Curves.fastOutSlowIn,
            animatable: Tween<double>(begin: 0.0, end: 1.0),
            from: Duration(milliseconds: 400),
            to: Duration(milliseconds: 500),
            tag: 'opacity')
        .addAnimatable(
            curve: Curves.fastOutSlowIn,
            animatable: Tween<double>(begin: 100, end: 148.0),
            from: Duration(milliseconds: 400),
            to: Duration(milliseconds: 1000),
            tag: 'size')
        .addAnimatable(
            curve: Curves.fastOutSlowIn,
            animatable: ColorTween(begin: AppColor.redColor, end: AppColor.bgColor),
            from: Duration(milliseconds: 400),
            to: Duration(milliseconds: 900),
            tag: 'color')
        .animate(iconsAnimationController);
    setHorizontalAnimation(isLeft: true);
    setVerticalAnimation(widget.items.value.length - 1);
    widget.swipe.listen((event) {
      if (event != null) {
        _dragExtent.value = event == SwipeDirection.left ? -0.0001 : 0.0001;
        horizontalAnimationController.value = 0.0;

        if (event == SwipeDirection.left) {
          swipeDirection.value = 'left';
          setHorizontalAnimation(isLeft: true);
        } else if (event == SwipeDirection.right) {
          swipeDirection.value = 'right';
          setHorizontalAnimation(isLeft: false);
        }
        Future.delayed(Duration(milliseconds: 50), () {
          horizontalAnimationController.forward();
        });
        iconsAnimationController.forward().then((value) {
          iconsAnimationController.reverse();
          widget.onSwipe(event, widget.items.value.length - 1);
        });
      }
    });
    horizontalAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_dragUnderway.value) {
        widget.onSwipe(swipeDirection.value == 'left' ? SwipeDirection.left : SwipeDirection.right,
            widget.items.value.length - 1);
        horizontalAnimationController.reset();
        iconsAnimationController.reverse();
      }
    });
    iconsAnimationController.addStatusListener((status) {
      if ((status == AnimationStatus.completed || status == AnimationStatus.dismissed) &&
          !_dragUnderway.value) {
        iconsAnimationController.reverse();
      }
    });
    super.initState();
  }

  @override
  dispose() {
    iconsAnimationController.removeStatusListener((value) {});
    horizontalAnimationController.removeStatusListener((value) {});
    iconsAnimationController.dispose();
    horizontalAnimationController.dispose();
    super.dispose();
  }

  bool get _isActive {
    return _dragUnderway.value || horizontalAnimationController.isAnimating;
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway.value = true;
    if (horizontalAnimationController.isAnimating) {
      _dragExtent.value =
          horizontalAnimationController.value * widget.fullWidth * _dragExtent.value.sign;
      horizontalAnimationController.stop();
    } else {
      _dragExtent.value = 0.0;
      horizontalAnimationController.value = 0.0;
    }
    setState(() {
      setHorizontalAnimation();
    });
  }

  setVerticalAnimation(int index) {
    double distance = widget.items.value.length - index - 1.0;
    verticalAnimation = SequenceAnimationBuilder()
        .addAnimatable(
            animatable: frontWidgetConstrains.minHeight.tweenTo(frontWidgetConstrains.maxHeight),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 500),
            tag: 'frontHeight')
        .addAnimatable(
            animatable: frontWidgetConstrains.minWidth.tweenTo(frontWidgetConstrains.maxWidth),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 500),
            tag: 'frontWidth')
        .addAnimatable(
            animatable: backWidgetFullHeight.tweenTo(0.0),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 500),
            tag: 'backHeight')
        .addAnimatable(
            animatable: (frontWidgetConstrains.maxWidth - 32.0).tweenTo(frontWidgetConstrains.minWidth),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 500),
            tag: 'backWidth')
        .addAnimatable(
            animatable: (index * 12.0).tweenTo(0.0),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 500),
            tag: 'topPosition')
        .addAnimatable(
            animatable: (distance * 12.0 - horizontalAnimation['backgroundIncrease'].value)
                .tweenTo(distance * 24.0),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 500),
            tag: 'backSide')
        .animate(verticalAnimationController);
    setState(() {});
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (!verticalAnimationController.isAnimating) {
      verticalAnimationController.value -= details.primaryDelta / frontWidgetConstrains.maxHeight;
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    animationCt(
        ctrl: verticalAnimationController, details: details, dim: frontWidgetConstrains.maxHeight);
  }

  animationCt({AnimationController ctrl, DragEndDetails details, double dim}) {
    if (ctrl.isAnimating || ctrl.status == AnimationStatus.completed) return;
    final double flingVelocity = details.velocity.pixelsPerSecond.dy / dim;
    if (flingVelocity < 0.0) {
      ctrl.fling(velocity: math.max(_kFlingVelocity, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      ctrl.fling(velocity: math.min(-_kFlingVelocity, -flingVelocity));
    } else {
      ctrl.fling(velocity: ctrl.value.abs() < .5 ? -_kFlingVelocity : _kFlingVelocity);
    }
  }

  setHorizontalAnimation({bool isLeft}) {
    final double end = _dragExtent.value.sign;

    horizontalAnimation = SequenceAnimationBuilder()
        .addAnimatable(
            curve: Curves.fastOutSlowIn,
            animatable: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(end, 0.0),
            ),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 800),
            tag: 'swipe')
        .addAnimatable(
            curve: Curves.fastOutSlowIn,
            animatable: Tween<double>(
              begin: 0.0,
              end: 16,
            ),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 800),
            tag: 'backgroundIncrease')
        .addAnimatable(
            curve: Curves.fastOutSlowIn,
            animatable: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ),
            from: Duration(milliseconds: 0),
            to: Duration(milliseconds: 800),
            tag: 'opacity')
        .animate(horizontalAnimationController);
    setState(() {});
  }

  void _handleHorizontalDragUpdate({DragUpdateDetails details, double dim, AnimationController ctrl}) {
    if (!_isActive || ctrl.isAnimating) return;
    final double delta = details.primaryDelta;
    final double oldDragExtent = _dragExtent.value;
    _dragExtent.value += delta;
    if (oldDragExtent.sign != _dragExtent.value.sign) {
      swipeDirection.value = _dragExtent.value.sign > 0 ? 'right' : 'left';
      setHorizontalAnimation();
    }
    if (!ctrl.isAnimating) {
      ctrl.value = _dragExtent.value.abs() / dim;
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details, double dim) {
    horizontalAnimationCt(ctrl: horizontalAnimationController, details: details, dim: dim);
    horizontalAnimationCt(ctrl: iconsAnimationController, details: details, dim: 140);
  }

  horizontalAnimationCt({AnimationController ctrl, DragEndDetails details, double dim}) {
    if (!_isActive || ctrl.isAnimating) return;
    _dragUnderway.value = false;
    if (ctrl.isAnimating || ctrl.status == AnimationStatus.completed) return;
    final double flingVelocity = details.velocity.pixelsPerSecond.dx / dim;
    if (flingVelocity < 0.0) {
      ctrl.fling(velocity: math.max(_kFlingVelocity, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      ctrl.fling(velocity: math.min(-_kFlingVelocity, -flingVelocity));
    } else {
      ctrl.fling(velocity: (ctrl.value.abs() < .5) ? -_kFlingVelocity : _kFlingVelocity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: widget.items,
      builder: (context, AsyncSnapshot<List<dynamic>> asyncItems) {
        if (asyncItems.hasData && asyncItems.data != null) {
          return AnimatedBuilder(
            animation: horizontalAnimationController,
            builder: (context, hrAnimation) {
              return Stack(
                children: <Widget>[
                  Stack(
                    children: asyncItems.data.map((e) {
                      var i = asyncItems.data.indexOf(e);
                      String categoryString = '';
                      for (var it in asyncItems.data[i].categories) {
                        if (categoryString == '') {
                          categoryString = it.title;
                        } else {
                          categoryString += ', ${it.title}';
                        }
                      }
                      return _buildItem(
                          child: asyncItems.data[i],
                          index: i,
                          categoryString: categoryString,
                          cardsLength: asyncItems.data.length);
                    }).toList(),
                  ),
                  AnimatedBuilder(
                      animation: iconsAnimationController,
                      builder: (context, snapshot) {
                        return iconsAnimationController.value > 0
                            ? Center(
                                child: Opacity(
                                    opacity: iconsAnimation['opacity'].value, child: _buildIcon()),
                              )
                            : SizedBox.shrink();
                      })
                ],
              );
            },
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildItem({RestaurantModel child, int index, int cardsLength, String categoryString}) {
    var orderFactor = widget.items.value.length - index - 1.0;
    var distanceFromSide = orderFactor * 12 - horizontalAnimation['backgroundIncrease'].value;
    return AnimatedBuilder(
        animation: verticalAnimationController,
        builder: (context, vrAnimation) {
          return Positioned(
              left: 16 + distanceFromSide,
              right: 16 + distanceFromSide,
              bottom: 0.0,
              top: verticalAnimationController.value > 0.0
                  ? verticalAnimation['topPosition'].value
                  : horizontalAnimation['backgroundIncrease'].value > 0.0
                      ? (((index <= 1 && cardsLength < 3 ? index + 1 : index) * 12) +
                          horizontalAnimation['backgroundIncrease'].value)
                      : ((index <= 1 && cardsLength < 3 ? index + 2 : index) * 12.0),
              child: Builder(
                builder: (context) {
                  if (cardsLength - 1 == index) {
                    return SlideTransition(
                      position: horizontalAnimation['swipe'],
                      child: _buildCard(child,
                          isWithGesture: true,
                          index: index,
                          distanceFromSide: distanceFromSide,
                          categoryString: categoryString,
                          length: cardsLength),
                    );
                  } else if (cardsLength - 2 == index || cardsLength - 3 == index) {
                    return _buildCard(child,
                        isWithGesture: false,
                        index: index,
                        distanceFromSide: distanceFromSide,
                        categoryString: categoryString,
                        length: cardsLength);
                  } else if (cardsLength >= 4 && index == cardsLength - 4) {
                    return Opacity(
                        opacity: horizontalAnimation['opacity'].value,
                        child: _buildCard(child,
                            isWithGesture: false,
                            index: index,
                            distanceFromSide: distanceFromSide,
                            categoryString: categoryString,
                            length: cardsLength));
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ));
        });
  }

  Widget _buildCard(RestaurantModel item,
      {@required bool isWithGesture,
      @required int index,
      @required int length,
      @required double distanceFromSide,
      @required categoryString}) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: (dragUpdate) {
        _handleHorizontalDragUpdate(
            ctrl: horizontalAnimationController,
            details: dragUpdate,
            dim: (MediaQuery.of(context).size.width * .8) * 1.8);
        _handleHorizontalDragUpdate(
            ctrl: iconsAnimationController, details: dragUpdate, dim: 148.0 * 1.8);
      },
      onHorizontalDragEnd: (dragEnd) {
        _handleHorizontalDragEnd(dragEnd, MediaQuery.of(context).size.width * .8);
      },
      onHorizontalDragCancel: () {
        horizontalAnimationController.reverse();
        iconsAnimationController.reverse();
      },
      onVerticalDragUpdate: (details) {
        _handleVerticalDragUpdate(details);
      },
      onVerticalDragEnd: (dragEnd) {
        _handleVerticalDragEnd(dragEnd);
      },
      child: BackDrop(
        distanceFromSide: BehaviorSubject.seeded(distanceFromSide),
        index: BehaviorSubject.seeded(index),
        frontLayerHeader: Container(
          height: verticalAnimation['frontHeight'].value,
          width: verticalAnimation['frontWidth'].value,
          constraints: frontWidgetConstrains,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(250, 141, 53, 0.5),
                  blurRadius: 16.0,
                  spreadRadius: 1.0,
                  offset: Offset(
                    8.0,
                    8.0,
                  ),
                ),
              ],
              borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[_buildTitleTile(item, categoryString), _buildListDrag(context)],
          ),
        ),
        backLayer: Container(
            width: verticalAnimation['backWidth'].value,
            height: verticalAnimation['backHeight'].value,
            child: buildCardImage(item)),
      ),
    );
  }

  Widget buildCardImage(RestaurantModel item) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(28)),
      child: CachedNetworkImage(
        imageUrl: item.imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return swipeDirection.value == 'right'
        ? Stack(
            children: <Widget>[
              Center(
                child: Container(
                    width: iconsAnimation['size'].value,
                    height: iconsAnimation['size'].value,
                    child: Center(
                      child: Image(
                        width: iconsAnimation['size'].value / 3,
                        height: iconsAnimation['size'].value / 3,
                        image: AssetImage(AppImages.icButtonCheckRed),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: iconsAnimation['color'].value,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(250, 141, 53, 0.5),
                          blurRadius: 16.0,
                          spreadRadius: 1.0,
                          offset: Offset(
                            8.0,
                            8.0,
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          )
        : Container(
            width: iconsAnimation['size'].value,
            height: iconsAnimation['size'].value,
            child: Image(
                width: iconsAnimation['size'].value,
                height: iconsAnimation['size'].value,
                image: AssetImage(AppImages.icCloseButton)));
  }

  Widget _buildTitleTile(RestaurantModel item, String categoryString) {
    return Container(
      constraints: BoxConstraints(maxHeight: 128),
      child: Column(
        children: <Widget>[
          Container(
            height: 32,
            margin: EdgeInsets.only(left: 20, right: 20, top: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              item?.name ?? '',
              style: AppStyle.style20MediumGrey,
            ),
          ),
          Container(
            height: 25,
            margin: EdgeInsets.only(left: 20, right: 20, top: 6),
            alignment: Alignment.centerLeft,
            child: Text(
              categoryString, //'Greek Cuisine',
              style: AppStyle.style15MediumBlack60,
            ),
          ),
          Container(
            height: 28,
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Row(
              children: <Widget>[
                //STAR
                Expanded(
                  child: Container(
                    height: 25,
                    margin: EdgeInsets.only(left: 0),
                    alignment: Alignment.centerLeft,
                    child: SmoothStarRating(
                        allowHalfRating: false,
                        onRatingChanged: (v) {},
                        starCount: 5,
                        rating: item?.rating ?? 5,
                        size: 25.0,
                        color: AppColor.bgColor,
                        borderColor: Colors.grey,
                        spacing: 0.0),
                  ),
                ),

                Container(
                  height: 28,
                  width: 64,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 0, right: 0),
                  decoration: BoxDecoration(
                      color: AppColor.bgColor.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Text(
                    item?.price ?? '', //'\$\$\$',
                    style: AppStyle.style14RegularRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListDrag(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .55,
      child: Column(
        children: <Widget>[
          _buildIndicatorPhotoMenu(context),
          Expanded(
              child: StreamBuilder<RestaurantModel>(
            stream: widget.stream,
            builder: (BuildContext context, AsyncSnapshot<RestaurantModel> data) {
              return (data.hasData && data.data != null)
                  ? Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: (data.data.photos).length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildItemEvent(context, (data.data.photos)[index], index);
                          }),
                    )
                  : Container();
            },
          )),
        ],
      ),
    );
  }

  Widget _buildItemEvent(BuildContext context, String item, int index) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 12.0, bottom: 12.0, right: 12),
      height: 208,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: CachedNetworkImage(
        imageUrl: item,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorPhotoMenu(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        height: 68,
        margin: EdgeInsets.only(top: 0, left: 8, right: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(0),
              height: 68,
              width: (MediaQuery.of(context).size.width - 62) / 2 - 8,
              alignment: Alignment.center,
              child: Container(
                height: 44,
                margin: EdgeInsets.only(left: 4, right: 4),
                width: (MediaQuery.of(context).size.width - 62) / 2 - 8,
                decoration: BoxDecoration(
                  color: widget.isPhoto ? AppColor.redColor : AppColor.bgColor.withOpacity(0.2),
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  onPressed: () {
                    widget.onImageTab();
                  },
                  child: Text(
                    'PHOTO',
                    style: widget.isPhoto ? AppStyle.style14BoldWhite : AppStyle.style14BoldRed,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(0),
              height: 68,
              alignment: Alignment.center,
              child: Container(
                height: 44,
                margin: EdgeInsets.only(left: 4, right: 4),
                width: (MediaQuery.of(context).size.width - 62) / 2 - 8,
                decoration: BoxDecoration(
                  color: widget.isPhoto ? AppColor.bgColor.withOpacity(0.2) : AppColor.redColor,
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  onPressed: () {
                    widget.onImageTab();
                  },
                  child: Text(
                    'MENU',
                    style: widget.isPhoto ? AppStyle.style14BoldRed : AppStyle.style14BoldWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
