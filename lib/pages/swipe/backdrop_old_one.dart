// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:meta/meta.dart';

// const _kFlingVelocity = 2.0;

// class _BackdropPanel extends StatelessWidget {
//   _BackdropPanel(
//       {Key key,
//       this.onTap,
//       this.onVerticalDragUpdate,
//       this.onVerticalDragEnd,
//       this.title,
//       this.child,
//       this.titleHeight,
//       this.padding,
//       this.backgroundColor,
//       this.onHorizontalDragEnd,
//       this.onHorizontalDragUpdate,
//       this.onVerticalDragStart,
//       this.onHorizontalDragStart,
//       this.onVerticalDragCancel,
//       this.onHorizontalDragCancel})
//       : super(key: key);

//   final VoidCallback onTap;
//   final GestureDragUpdateCallback onVerticalDragUpdate;
//   final GestureDragEndCallback onVerticalDragEnd;
//   final GestureDragStartCallback onVerticalDragStart;
//   final GestureDragUpdateCallback onHorizontalDragUpdate;
//   final GestureDragEndCallback onHorizontalDragEnd;
//   final GestureDragStartCallback onHorizontalDragStart;
//   final GestureDragCancelCallback onHorizontalDragCancel;
//   final GestureDragCancelCallback onVerticalDragCancel;
//   final Widget title;
//   final Widget child;
//   final double titleHeight;
//   final EdgeInsets padding;
//   Color backgroundColor;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: padding,
//       child: Material(
//         color: backgroundColor,
//         borderRadius: BorderRadius.all(Radius.circular(28.0)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onVerticalDragUpdate: onVerticalDragUpdate,
//               onVerticalDragEnd: onVerticalDragEnd,
//               onVerticalDragStart: onVerticalDragStart,
//               onHorizontalDragUpdate: onHorizontalDragUpdate,
//               onHorizontalDragEnd: onHorizontalDragEnd,
//               onVerticalDragCancel: onVerticalDragCancel,
//               onHorizontalDragCancel: onHorizontalDragCancel,
//               onTap: onTap,
//               child: Container(height: titleHeight, child: title),
//             ),
//             Expanded(
//               child: child,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Backdrop extends StatefulWidget {
//   final Widget frontLayer;
//   final Widget backLayer;
//   final Widget frontHeader;
//   final double frontPanelOpenHeight;
//   final double frontHeaderHeight;
//   final bool frontHeaderVisibleClosed;
//   final EdgeInsets frontPanelPadding;
//   final ValueNotifier<bool> panelVisible;
//   final GestureDragUpdateCallback onVerticalDragUpdate;
//   final GestureDragEndCallback onVerticalDragEnd;
//   final GestureDragStartCallback onVerticalDragStart;
//   final GestureDragUpdateCallback onHorizontalDragUpdate;
//   final GestureDragEndCallback onHorizontalDragEnd;
//   final GestureDragStartCallback onHorizontalDragStart;
//   final GestureDragCancelCallback onHorizontalDragCancel;
//   final GestureDragCancelCallback onVerticalDragCancel;
//   Backdrop(
//       {@required this.frontLayer,
//       @required this.backLayer,
//       this.frontPanelOpenHeight = 0.0,
//       this.frontHeaderHeight = 48.0,
//       this.frontPanelPadding = const EdgeInsets.all(0.0),
//       this.frontHeaderVisibleClosed = true,
//       this.panelVisible,
//       this.frontHeader,
//       this.onHorizontalDragStart,
//       this.onVerticalDragStart,
//       this.onHorizontalDragUpdate,
//       this.onHorizontalDragEnd,
//       this.onVerticalDragEnd,
//       this.onVerticalDragUpdate,
//       this.onHorizontalDragCancel,
//       this.onVerticalDragCancel})
//       : assert(frontLayer != null),
//         assert(backLayer != null);

//   @override
//   createState() => _BackdropState();
// }

// class _BackdropState extends State<Backdrop>
//     with SingleTickerProviderStateMixin {
//   final _backdropKey = GlobalKey(debugLabel: 'Backdrop');
//   AnimationController _controller;
//   Color color = Colors.white.withOpacity(0.0);

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 300),
//       value: (widget.panelVisible?.value ?? true) ? 1.0 : 0.0,
//       vsync: this,
//     );
//     widget.panelVisible?.addListener(_subscribeToValueNotifier);

//     if (widget.panelVisible != null) {
//       _controller.addStatusListener((status) {
//         if (status == AnimationStatus.completed)
//           widget.panelVisible.value = true;
//         else if (status == AnimationStatus.dismissed)
//           widget.panelVisible.value = false;
//       });
//     }
//   }

//   void _subscribeToValueNotifier() {
//     if (widget.panelVisible.value != _backdropPanelVisible)
//       _toggleBackdropPanelVisibility();
//   }

//   @override
//   void didUpdateWidget(Backdrop oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     oldWidget.panelVisible?.removeListener(_subscribeToValueNotifier);
//     widget.panelVisible?.addListener(_subscribeToValueNotifier);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     widget.panelVisible?.dispose();
//     super.dispose();
//   }

//   bool get _backdropPanelVisible =>
//       _controller.status == AnimationStatus.completed ||
//       _controller.status == AnimationStatus.forward;

//   void _toggleBackdropPanelVisibility() {
//     color = Colors.white;
//     setState(() {});
//     _controller
//         .fling(
//             velocity:
//                 _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity)
//         .then((val) {
//       //HADLE COLOR
//       color =
//           _backdropPanelVisible ? Colors.white : Colors.white.withOpacity(0.0);
//       setState(() {});
//     });
//   }

//   double get _backdropHeight {
//     final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
//     return renderBox.size.height;
//   }

//   void _handleDragUpdate(DragUpdateDetails details) {
//     widget.onVerticalDragUpdate(details);
//     color = Colors.white;
//     setState(() {});
//     if (!_controller.isAnimating) {
//       _controller.value -= details.primaryDelta / _backdropHeight;
//     }
//   }

//   void _handleDragEnd(DragEndDetails details) {
//     widget.onVerticalDragEnd(details);
//     if (_controller.isAnimating ||
//         _controller.status == AnimationStatus.completed) return;

//     final double flingVelocity =
//         details.velocity.pixelsPerSecond.dy / _backdropHeight;
//     if (flingVelocity < 0.0) {
//       _controller.fling(velocity: math.max(_kFlingVelocity, -flingVelocity));
//     } else if (flingVelocity > 0.0) {
//       _controller.fling(velocity: math.min(-_kFlingVelocity, -flingVelocity));
//     } else {
//       _controller
//           .fling(
//               velocity:
//                   _controller.value < 0.5 ? -_kFlingVelocity : _kFlingVelocity)
//           .then((value) {
//         //HADLE COLOR
//         color = _controller.value >= 0.5
//             ? Colors.white
//             : Colors.white.withOpacity(0.0);
//         setState(() {});
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final panelSize = constraints.biggest;
//       final closedPercentage = widget.frontHeaderVisibleClosed
//           ? (panelSize.height - widget.frontHeaderHeight) / panelSize.height
//           : 1.0;
//       final openPercentage = widget.frontPanelOpenHeight / panelSize.height;

//       final panelDetailsPosition = Tween<Offset>(
//         begin: Offset(0.0, closedPercentage),
//         end: Offset(0.0, openPercentage),
//       ).animate(_controller.view);

//       return Container(
//         key: _backdropKey,
//         child: Stack(
//           children: <Widget>[
//             widget.backLayer,
//             SlideTransition(
//               position: panelDetailsPosition,
//               child: _BackdropPanel(
//                 onTap: _toggleBackdropPanelVisibility,
//                 onVerticalDragUpdate: _handleDragUpdate,
//                 onVerticalDragEnd: _handleDragEnd,
//                 onVerticalDragStart: widget.onVerticalDragStart,
//                 onHorizontalDragEnd: widget.onHorizontalDragEnd,
//                 onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
//                 onHorizontalDragStart: widget.onHorizontalDragStart,
//                 onHorizontalDragCancel: widget.onHorizontalDragCancel,
//                 onVerticalDragCancel: widget.onVerticalDragCancel,
//                 title: Container(
//                     margin: EdgeInsets.only(
//                         left: _controller.value >= 0.5 ? 0 : 20,
//                         right: _controller.value >= 0.5 ? 0 : 20),
//                     child: widget.frontHeader),
//                 titleHeight: widget.frontHeaderHeight,
//                 child: widget.frontLayer,
//                 padding: widget.frontPanelPadding,
//                 backgroundColor: color,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
