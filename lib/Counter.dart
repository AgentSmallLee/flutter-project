import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  final String name = '22';

  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    // 初始化
  }

  void _increment() {
    if (mounted) {
      setState(() {
        _count++;
      });
    }
  }

  @override
  void dispose() {
    // 清理资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(context);
    return TextButton(onPressed: _increment, child: Text('Count: $_count'));
  }
}
