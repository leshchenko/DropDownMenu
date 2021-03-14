import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          backgroundColor: Colors.blue,
          body: Center(
            child: DropDownMenu(
              button: Container(
                color: Colors.yellow,
                width: 100,
                height: 100,
              ),
              menu: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Logout'),
                  SizedBox(height: 8),
                  Text('Switch Profile'),
                  SizedBox(height: 8),
                  Text('Settings'),
                  SizedBox(height: 8),
                  Text('Night Mode'),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ));
  }
}

class DropDownMenu extends StatefulWidget {
  DropDownMenu({this.button, this.menu, Key key}) : super(key: key);
  final Widget menu;
  final Widget button;

  @override
  _DropDownMenuState createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(_toggleMenu),
      child: widget.button,
    );
  }

  void _toggleMenu() {
    _isVisible = !_isVisible;
    if (_isVisible) {
      displayMenu();
    } else {
      Navigator.of(context).pop();
    }
  }

  void displayMenu() {
    var renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.localToGlobal(Offset(0, renderBox.size.height));
    Navigator.push(
      context,
      _MenuRoute(
        position: position,
        menu: ConstrainedBox(
          constraints: BoxConstraints(minWidth: renderBox.size.width),
          child: widget.menu,
        ),
      ),
    ).then((value) => _isVisible = false);
  }
}

class _MenuRoute<T> extends PopupRoute<T> {
  _MenuRoute({
    this.position,
    this.menu,
  });

  final Offset position;
  final Widget menu;

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Animation<double> createAnimation() => CurvedAnimation(
        parent: super.createAnimation(),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 0.01), end: Offset.zero).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: CustomSingleChildLayout(
            delegate: _MenuRouteLayout(
              position,
            ),
            child: CustomPaint(
              child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: menu,
                  )),
              painter: TriangleMenuPainter(),
            ),
          ),
        ),
      );
}

/// Positioning of the menu on the screen.
class _MenuRouteLayout extends SingleChildLayoutDelegate {
  _MenuRouteLayout(this.position);

  final Offset position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(position.dx, position.dy);

  @override
  bool shouldRelayout(_MenuRouteLayout oldDelegate) => position != oldDelegate.position;
}

class TriangleMenuPainter extends CustomPainter {
  Paint _paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..strokeWidth = 10;
  double triangleSize = 8;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(0, triangleSize);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, triangleSize);
    path.lineTo(size.width - triangleSize, triangleSize);
    path.lineTo(size.width - triangleSize * 1.5, 0);
    path.lineTo(size.width - triangleSize * 2, triangleSize);
    path.lineTo(0, triangleSize);
    path.close();
    canvas.drawPath(path, _paint);
  }
}
