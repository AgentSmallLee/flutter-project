import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CounterPage());
  }
}

/// 父组件：持有状态，负责“提升”后的管理
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('状态提升示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 子组件1：只负责展示，数据由父组件传入
            CountDisplay(count: _count),
            const SizedBox(height: 20),
            // 子组件2：只负责触发事件，通过回调通知父组件
            IncrementButton(onPressed: _increment),
          ],
        ),
      ),
    );
  }
}

/// 展示组件：StatelessWidget，不持有状态
class CountDisplay extends StatelessWidget {
  final int count;

  const CountDisplay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text('当前计数：$count', style: const TextStyle(fontSize: 24));
  }
}

/// 按钮组件：StatelessWidget，通过回调向上通知
class IncrementButton extends StatelessWidget {
  final VoidCallback onPressed;

  const IncrementButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('加一'),
    );
  }
}