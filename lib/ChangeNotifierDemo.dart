import 'package:flutter/material.dart';

/// 一个简单的计数器 Model，继承自 ChangeNotifier
/// 当内部数据变化时，调用 notifyListeners() 通知监听者
class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 通知所有监听者刷新
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

class ChangeNotifierDemo extends StatefulWidget {
  const ChangeNotifierDemo({super.key});

  @override
  State<ChangeNotifierDemo> createState() => _ChangeNotifierDemoState();
}

class _ChangeNotifierDemoState extends State<ChangeNotifierDemo> {
  // 创建 Model 实例
  final CounterModel _counter = CounterModel();

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChangeNotifier 演示')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('当前计数：'),
            // 用 ListenableBuilder 包裹，只有这里会在计数变化时重建
            ListenableBuilder(
              listenable: _counter,
              builder: (context, child) {
                return Text(
                  '${_counter.count}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _counter.decrement,
                  child: const Icon(Icons.remove),
                ),
                ElevatedButton(
                  onPressed: _counter.increment,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              '说明：CounterModel 继承 ChangeNotifier，\n'
              '调用 notifyListeners() 通知监听者刷新 UI',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
