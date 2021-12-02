import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Offset _startLastOffset;
  late Offset _lastOffset;
  late Offset _currentOffset;
  late double _lastScale;
  late double _currentScale;

  void _onScaleStart(ScaleStartDetails details) {
    print('ScaleStartDetails: $details');

    _startLastOffset = details.focalPoint;
    _lastOffset = _currentOffset;
    _lastScale = _currentScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    print('ScaleUpdateDetails: $details - Scale: ${details.scale}');
    if (details.scale != 1.0) {
      // Scaling
      double currentScale = _lastScale * details.scale;
      if (currentScale < 0.5) currentScale = 0.5;
      setState(() => _currentScale = currentScale);
      print('_scale: $_currentScale - _lastScale: $_lastScale');
    } else if (details.scale == 1.0) {
      // We are not scaling but dragging around screen
      // Calculate Offset depending on current Image scaling.
      Offset offsetAdjustedForScale =
          (_startLastOffset - _lastOffset) / _lastScale;
      Offset currentOffset =
          details.focalPoint - (offsetAdjustedForScale * _currentScale);
      setState(() {
        _currentOffset = currentOffset;
      });
      print(
          'offsetAdjustedForScale: $offsetAdjustedForScale - _currentOffset: $_currentOffset');
    }
  }

  void _onDoubleTap() {
    print('onDoubleTap');

    // Calculate current scale and populate the _lastScale with currentScale
    // if currentScale is greater than 16 times the original image, reset scale to default, 1.0
    double currentScale = _lastScale * 2.0;
    if (currentScale > 16.0) {
      currentScale = 1.0;
      _resetToDefaultValues();
    }
    _lastScale = currentScale;
    setState(() => _currentScale = currentScale);
  }

  void _onLongPress() {
    print('onLongPress');
    setState(() => _resetToDefaultValues());
  }

  void _resetToDefaultValues() {
    _startLastOffset = Offset.zero;
    _lastOffset = Offset.zero;
    _currentOffset = Offset.zero;
    _lastScale = 1.0;
    _currentScale = 1.0;
  }

  void _setScaleSmall() {
    setState(() => _currentScale = 0.5);
  }

  void _setScaleBig() {
    setState(() => _currentScale = 16.0);
  }

  @override
  void initState() {
    super.initState();
    _resetToDefaultValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestures & Scale'),
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  GestureDetector _buildBody(BuildContext context) {
    return GestureDetector(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // _transformScaleAndTranslate(),
          _transformMatrix4(),
          _positionedStatusBar(context),
          _positionedInkWellAndInkResponse(context),
        ],
      ),
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onDoubleTap: _onDoubleTap,
      onLongPress: _onLongPress,
    );
  }

  Positioned _positionedInkWellAndInkResponse(BuildContext context) {
    return Positioned(
      top: 50.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white54,
        height: 56.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              child: Container(
                height: 48.0,
                width: 128.0,
                color: Colors.black12,
                child: const Icon(Icons.touch_app, size: 32.0),
              ),
              splashColor: Colors.lightGreenAccent,
              highlightColor: Colors.lightBlueAccent,
              onTap: _setScaleSmall,
              onDoubleTap: _setScaleBig,
              onLongPress: _onLongPress,
            ),
          ],
        ),
      ),
    );
  }

  Transform _transformScaleAndTranslate() {
    return Transform.scale(
      scale: _currentScale,
      child: Transform.translate(
        offset: _currentOffset,
        child: const Image(
          image: AssetImage('assets/images/elephant.jpg'),
        ),
      ),
    );
  }

  Transform _transformMatrix4() {
    return Transform(
      transform: Matrix4.identity()
        ..scale(_currentScale, _currentScale)
        ..translate(_currentOffset.dx, _currentOffset.dy),
      alignment: FractionalOffset.center,
      child: const Image(
        image: AssetImage('assets/images/elephant.jpg'),
      ),
    );
  }

  Positioned _positionedStatusBar(context) {
    return Positioned(
      top: 0.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white54,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Scale: ${_currentScale.toStringAsFixed(4)}'),
            Text('Current: $_currentOffset'),
          ],
        ),
      ),
    );
  }
}
