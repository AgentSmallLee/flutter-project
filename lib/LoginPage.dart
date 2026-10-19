import 'package:flutter/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required String desc});

  @override
  Widget build(BuildContext context) {
    print(context);
    return const Text(
      '登录页面',
      style: TextStyle(decoration: TextDecoration.none),
    );
  }
}
