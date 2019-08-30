import 'package:flutter/material.dart';

const _loadingPeriod = 700;
const _indicatorHeight = 2.0;

/// 仿照抖音和快手的进度条效果，含有Loading
/// A progress bar like kuaishou, tik tok (douyin), including loading.
class LinearProgressIndicator extends ProgressIndicator {
  /// Creates a linear loading indicator.
  const LinearProgressIndicator({
    Key key,
    double value,
    Color backgroundColor,
    Animation<Color> valueColor,
    this.showInCenter = false,
    this.loopAround = false,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
        );

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).backgroundColor;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).accentColor;

  /// 进度显示在中间
  /// progress in center and zoom in.
  final bool showInCenter;

  /// 是否往返循环,
  /// action after reaching the edge, true, zoom out back to origin.
  final bool loopAround;

  @override
  _LinearLoadingIndicatorState createState() => _LinearLoadingIndicatorState();
}

class _LinearLoadingIndicatorState extends State<LinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _loadingPeriod),
      vsync: this,
    );

    if (widget.value == null) {
      if (widget.loopAround) {
        _controller.forward();
        _controller.addListener(() {
          /// reach the max, reverse
          if (_controller.value == 1) {
            _controller.reverse();
          } else if (_controller.value == 0) {
            /// reversing, reach the min, start zoom in animation.
            _controller.forward();
          }
        });
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(LinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double animationValue,
      TextDirection textDirection) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: _indicatorHeight,
      ),
      child: CustomPaint(
        painter: _LinearLoadingIndicatorPainter(
          backgroundColor: widget._getBackgroundColor(context),
          valueColor: widget._getValueColor(context),
          value: widget.value,
          // may be null
          animationValue: animationValue,
          showInCenter: widget.showInCenter ?? false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null)
      return _buildIndicator(context, _controller.value, textDirection);

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(context, _controller.value, textDirection);
      },
    );
  }
}

class _LinearLoadingIndicatorPainter extends CustomPainter {
  const _LinearLoadingIndicatorPainter({
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.animationValue,
    this.showInCenter = false,
  });

  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double animationValue;
  final bool showInCenter;

  static const Curve zoomIn = Interval(0, 1, curve: Curves.easeIn);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = valueColor;

    if (value != null) {
      drawBar(
          showInCenter: showInCenter,
          canvas: canvas,
          paint: paint,
          size: size,
          x: value.clamp(0.0, 1.0) * size.width,
          width: size.width);
    } else {
      final double x1 = size.width * zoomIn.transform(animationValue);
      drawBar(
          showInCenter: showInCenter,
          canvas: canvas,
          paint: paint,
          size: size,
          x: x1,
          width: size.width);
    }
  }

  void drawBar(
      {@required bool showInCenter,
      @required Canvas canvas,
      @required Paint paint,
      @required Size size,
      @required double x,
      @required double width}) {
    if (showInCenter ?? false) {
      drawCenterBar(
          canvas: canvas, paint: paint, size: size, x: x, width: width);
    } else {
      drawNormalBar(
          canvas: canvas, paint: paint, size: size, x: x, width: width);
    }
  }

  /// calculate the offset of indicator.
  void drawCenterBar(
      {@required Canvas canvas,
      @required Paint paint,
      @required Size size,
      @required double x,
      @required double width}) {
    if (x <= 0.0 || x > width) {
      return;
    }

    final double left = (width - x) / 2;
    canvas.drawRect(Offset(left, 0.0) & Size(x, size.height), paint);
  }

  /// calculate the offset of indicator.
  void drawNormalBar(
      {@required Canvas canvas,
      @required Paint paint,
      @required Size size,
      @required double x,
      @required double width}) {
    if (x <= 0.0 || x > width) {
      return;
    }

    canvas.drawRect(Offset(0, 0.0) & Size(x, size.height), paint);
  }

  @override
  bool shouldRepaint(_LinearLoadingIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.animationValue != animationValue;
  }
}
