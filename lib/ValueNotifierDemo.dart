import 'package:flutter/material.dart';

class ValueNotifierDemo extends StatefulWidget {
  const ValueNotifierDemo({super.key});

  @override
  State<ValueNotifierDemo> createState() => _ValueNotifierDemoState();
}

class _ValueNotifierDemoState extends State<ValueNotifierDemo> {
  // 单个值的场景：计数器
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  // 字符串场景：输入框内容同步
  final ValueNotifier<String> _inputText = ValueNotifier<String>('');

  // 复杂对象场景：用户信息（需要手动调用 value = newValue 才能触发通知）
  final ValueNotifier<User> _user = ValueNotifier<User>(User(name: '小明', age: 18));

  // 用于 select 场景的演示
  final ValueNotifier<ComplexData> _complexData = ValueNotifier<ComplexData>(
    ComplexData(title: '标题', count: 0, isOn: false),
  );

  @override
  void dispose() {
    _counter.dispose();
    _inputText.dispose();
    _user.dispose();
    _complexData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ValueNotifier 演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== 场景 1：计数器 ==========
            _buildSection(
              title: '场景 1：计数器（单个 int 值）',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _counter.value--,
                    child: const Icon(Icons.remove),
                  ),
                  // 只有这个 Text 会重建
                  ValueListenableBuilder<int>(
                    valueListenable: _counter,
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => _counter.value++,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            // ========== 场景 2：输入框内容同步 ==========
            _buildSection(
              title: '场景 2：输入框内容实时同步',
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => _inputText.value = value,
                    decoration: const InputDecoration(
                      labelText: '请输入内容',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: _inputText,
                    builder: (context, value, child) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue.shade50,
                        child: Text('你输入了：$value'),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ========== 场景 3：复杂对象 ==========
            _buildSection(
              title: '场景 3：复杂对象（整体替换）',
              child: Column(
                children: [
                  ValueListenableBuilder<User>(
                    valueListenable: _user,
                    builder: (context, user, child) {
                      return ListTile(
                        tileColor: Colors.green.shade50,
                        title: Text(user.name),
                        subtitle: Text('${user.age} 岁'),
                        leading: const Icon(Icons.person),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 必须整体替换对象，不能直接修改属性
                            _user.value = User(
                              name: '小红',
                              age: _user.value.age,
                            );
                          },
                          child: const Text('改名'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _user.value = User(
                              name: _user.value.name,
                              age: _user.value.age + 1,
                            );
                          },
                          child: const Text('涨一岁'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ========== 场景 4：child 参数优化 ==========
            _buildSection(
              title: '场景 4：child 参数（不需要重建的部分）',
              child: ValueListenableBuilder<int>(
                valueListenable: _counter,
                // child 参数里的 widget 不会重建
                child: const Text('这是固定不变的标题', style: TextStyle(fontWeight: FontWeight.bold)),
                builder: (context, value, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade50,
                    child: Column(
                      children: [
                        child!, // 复用 child，不重建
                        const SizedBox(height: 8),
                        Text('计数：$value'),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              '总结：ValueNotifier 适合单个值的状态管理，\n'
              '配合 ValueListenableBuilder 实现局部刷新，\n'
              '简单、轻量、无需第三方库。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ===================== 数据模型 =====================

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

class ComplexData {
  final String title;
  final int count;
  final bool isOn;

  ComplexData({required this.title, required this.count, required this.isOn});
}
