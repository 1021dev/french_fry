import 'package:flutter/widgets.dart';
enum SwipeDirection { left, right, up, down}
class SwipeGestureRecognizer extends StatefulWidget {
  final Function(DragUpdateDetails) onSwipeLeft;
  final Function(DragUpdateDetails) onSwipeRight;
  final Function(DragUpdateDetails) onSwipeUp;
  final Function(DragUpdateDetails) onSwipeDown;
  final Function(DragEndDetails) onSwipeLeftComplete;
  final Function(DragEndDetails) onSwipeRightComplete;
  final Function(DragEndDetails) onSwipeUpComplete;
  final Function(DragEndDetails) onSwipeDownComplete;
  final Widget child;
  SwipeGestureRecognizer(
      {Key key,
      this.child,
      this.onSwipeDown,
      this.onSwipeLeft,
      this.onSwipeRight,
      this.onSwipeUp,
      this.onSwipeDownComplete,
      this.onSwipeLeftComplete,
      this.onSwipeRightComplete,
      this.onSwipeUpComplete})
      : super(key: key);

  @override
  _SwipeGestureRecognizerState createState() => _SwipeGestureRecognizerState();
}

class _SwipeGestureRecognizerState extends State<SwipeGestureRecognizer> {
  Offset _horizontalSwipeStartingOffset;
  Offset _verticalSwipeStartingOffset;

  bool _isSwipeLeft;
  bool _isSwipeRight;
  bool _isSwipeUp;
  bool _isSwipeDown;

  @override
  void initState() {
    super.initState();
    _horizontalSwipeStartingOffset =
        _horizontalSwipeStartingOffset = Offset(0, 0);
    _isSwipeDown = _isSwipeUp = _isSwipeRight = _isSwipeLeft = false;
  }

  @override
  Widget build(BuildContext context) {
    return (widget.onSwipeLeft != null || widget.onSwipeRight != null) &&
            (widget.onSwipeDown != null || widget.onSwipeUp != null)
        ? GestureDetector(
            child: widget.child,
            onHorizontalDragStart: (details) {
              _horizontalSwipeStartingOffset = details.localPosition;
            },
            onHorizontalDragUpdate: (details) {
              if (_horizontalSwipeStartingOffset.dx >
                  details.localPosition.dx) {
                _isSwipeLeft = true;
                _isSwipeRight = false;
                widget.onSwipeLeft(details);
              } else {
                _isSwipeRight = true;
                _isSwipeLeft = false;
                widget.onSwipeRight(details);
              }
            },
            onHorizontalDragEnd: (details) {
              if (_isSwipeLeft) {
                if (widget.onSwipeLeft != null) {
                  widget.onSwipeLeftComplete(details);
                }
              } else if (_isSwipeRight) {
                if (widget.onSwipeRight != null) {
                  widget.onSwipeRightComplete(details);
                }
              }
            },
            onVerticalDragStart: (details) {
              _verticalSwipeStartingOffset = details.localPosition;
            },
            onVerticalDragUpdate: (details) {
              if (_verticalSwipeStartingOffset.dy > details.localPosition.dy) {
                _isSwipeUp = true;
                _isSwipeDown = false;
                widget.onSwipeUp(details);
              } else {
                _isSwipeDown = true;
                _isSwipeUp = false;
                widget.onSwipeDown(details);
              }
            },
            onVerticalDragEnd: (details) {
              if (_isSwipeUp && widget.onSwipeUp != null) {
                widget.onSwipeUpComplete(details);
              } else if (_isSwipeDown && widget.onSwipeDown != null) {
                widget.onSwipeDownComplete(details);
              }
            },
          )
        : (widget.onSwipeLeft != null || widget.onSwipeRight != null)
            ? GestureDetector(
                child: widget.child,
                onHorizontalDragStart: (details) {
                  _horizontalSwipeStartingOffset = details.localPosition;
                },
                onHorizontalDragUpdate: (details) {
                  if (_horizontalSwipeStartingOffset.dx >
                      details.localPosition.dx) {
                    _isSwipeLeft = true;
                    _isSwipeRight = false;
                  } else {
                    _isSwipeRight = true;
                    _isSwipeLeft = false;
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (_isSwipeLeft && widget.onSwipeLeft != null) {
                    widget.onSwipeLeftComplete(details);
                  } else if (_isSwipeRight && widget.onSwipeRight != null) {
                    widget.onSwipeRightComplete(details);
                  }
                },
              )
            : (widget.onSwipeDown != null || widget.onSwipeUp != null)
                ? GestureDetector(
                    child: widget.child,
                    onVerticalDragStart: (details) {
                      _verticalSwipeStartingOffset = details.localPosition;
                    },
                    onVerticalDragUpdate: (details) {
                      if (_verticalSwipeStartingOffset.dy >
                          details.localPosition.dy) {
                        _isSwipeUp = true;
                        _isSwipeDown = false;
                        widget.onSwipeUp(details);
                      } else {
                        _isSwipeDown = true;
                        _isSwipeUp = false;
                        widget.onSwipeDown(details);
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (_isSwipeUp && widget.onSwipeUp != null) {
                        widget.onSwipeUpComplete(details);
                      } else if (_isSwipeDown && widget.onSwipeDown != null) {
                        widget.onSwipeDownComplete(details);
                      }
                    },
                  )
                : SizedBox.shrink();
  }
}
