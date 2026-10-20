import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ===================== Model 层 =====================

/// 计数器 Model（继承 ChangeNotifier）
class CounterModel with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

/// 用户信息 Model
class UserModel with ChangeNotifier {
  String _name = '张三';
  int _age = 20;

  String get name => _name;
  int get age => _age;

  void changeName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void birthday() {
    _age++;
    notifyListeners();
  }
}

// ===================== 主页面 =====================

class ProviderDemo extends StatelessWidget {
  const ProviderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 用 MultiProvider 同时注册多个 Model
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Provider 状态管理演示')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CounterSection(),
              SizedBox(height: 24),
              _UserSection(),
              SizedBox(height: 24),
              _ProviderOfSection(),
              SizedBox(height: 24),
              _SelectorSection(),
              SizedBox(height: 24),
              _SelectSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 场景 1：基础用法 =====================

class _CounterSection extends StatelessWidget {
  const _CounterSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '场景 1：基础用法（Consumer）',
      child: Column(
        children: [
          // 用 Consumer 包裹，只有这里会重建
          Consumer<CounterModel>(
            builder: (context, counter, child) {
              return Text(
                '计数：${counter.count}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                // 用 read 获取 model，不订阅
                onPressed: () => context.read<CounterModel>().decrement(),
                child: const Icon(Icons.remove),
              ),
              ElevatedButton(
                onPressed: () => context.read<CounterModel>().increment(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '提示：按钮用 read() 获取 model，不参与重建；\n'
            '显示数字用 Consumer，只有它会刷新。',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ===================== 场景 2：多 Model 共享 =====================

class _UserSection extends StatelessWidget {
  const _UserSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '场景 2：多 Model + 细粒度 select',
      child: Column(
        children: [
          // 只监听 name 变化
          _SelectableName(),
          const SizedBox(height: 8),
          // 只监听 age 变化
          _SelectableAge(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<UserModel>().changeName('李四'),
                  child: const Text('改名'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<UserModel>().birthday(),
                  child: const Text('过生日'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '提示：用 select 只监听关心的字段，\n'
            '改 age 时 name 那一行不会重建。',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SelectableName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 用 select 细粒度监听：只关心 name
    final name = context.select<UserModel, String>((user) => user.name);
    print('🔵 _SelectableName build - name: $name');

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.person),
          const SizedBox(width: 8),
          Text('姓名：$name', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _SelectableAge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 用 select 细粒度监听：只关心 age
    final age = context.select<UserModel, int>((user) => user.age);
    print('🟢 _SelectableAge build - age: $age');

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade50,
      child: Row(
        children: [
          const Icon(Icons.cake),
          const SizedBox(width: 8),
          Text('年龄：$age 岁', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

// ===================== 场景 3：Provider.of 的两种用法 =====================

class _ProviderOfSection extends StatefulWidget {
  const _ProviderOfSection();

  @override
  State<_ProviderOfSection> createState() => _ProviderOfSectionState();
}

class _ProviderOfSectionState extends State<_ProviderOfSection> {
  String _readValue = '点击按钮用 read / listen:false 读取';

  @override
  Widget build(BuildContext context) {
    // 写法 1：Provider.of + listen: true → 订阅，会重建（等价于 context.watch）
    final counter = Provider.of<CounterModel>(context, listen: true);
    print('🟡 _ProviderOfSection build - count: ${counter.count}');

    return _SectionCard(
      title: '场景 3：Provider.of 的两种用法',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.yellow.shade50,
            child: Text(
              'Provider.of(listen:true) 读取：${counter.count}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Text(_readValue, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // 写法 2：Provider.of + listen: false → 不订阅，不重建（等价于 context.read）
                  onPressed: () {
                    final counter = Provider.of<CounterModel>(context, listen: false);
                    setState(() {
                      _readValue = 'listen:false 读取到：${counter.count}（不会订阅，不触发重建）';
                    });
                  },
                  child: const Text('Provider.of listen:false'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<CounterModel>().increment(),
                  child: const Text('+1（read 调用）'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '说明：\n'
            '• Provider.of<T>(ctx, listen: true) ≡ context.watch<T>()\n'
            '• Provider.of<T>(ctx, listen: false) ≡ context.read<T>()\n'
            '• watch / read 是语法糖，本质上还是 Provider.of',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ===================== 场景 4：Selector 细粒度局部重建 =====================

class _SelectorSection extends StatelessWidget {
  const _SelectorSection();

  @override
  Widget build(BuildContext context) {
    print('🎯 _SelectorSection 外层 build（整个方法不会因数据变化重建）');

    return _SectionCard(
      title: '场景 4：Selector 细粒度局部重建',
      child: Column(
        children: [
          // 这块 Container 是固定的，不会重建
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: const Text('外层容器（不随数据变化重建）'),
          ),
          const SizedBox(height: 12),
          // 只有 Selector 的 builder 里的内容会在 name 变化时重建
          Selector<UserModel, String>(
            selector: (context, user) => user.name,
            builder: (context, name, child) {
              print('🔵 Selector<name> build - name: $name');
              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade50,
                child: Text('姓名：$name'),
              );
            },
          ),
          const SizedBox(height: 8),
          // 只有 Selector 的 builder 里的内容会在 age 变化时重建
          Selector<UserModel, int>(
            selector: (context, user) => user.age,
            builder: (context, age, child) {
              print('🟢 Selector<age> build - age: $age');
              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.green.shade50,
                child: Text('年龄：$age 岁'),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<UserModel>().changeName('王五'),
                  child: const Text('改名'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<UserModel>().birthday(),
                  child: const Text('过生日'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '说明：\n'
            '• Selector 等价于 Consumer + select 的组合\n'
            '• 只有 builder 内部会重建，外部 widget 不受影响\n'
            '• 对比 context.select：select 会让整个 build 重建，\n'
            '  Selector 只重建 builder 里的部分',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ===================== 场景 5：各种获取方式对比 =====================

class _SelectSection extends StatelessWidget {
  const _SelectSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '场景 5：所有获取方式对比表',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MethodRow(name: 'Provider.of<T>(ctx, listen: true)', desc: '原始写法，全量订阅，会重建'),
          _MethodRow(name: 'context.watch<T>()', desc: '语法糖，等价于上面，会重建'),
          _MethodRow(name: 'Provider.of<T>(ctx, listen: false)', desc: '原始写法，只拿不订阅，不重建'),
          _MethodRow(name: 'context.read<T>()', desc: '语法糖，等价于上面，不重建（按钮回调首选）'),
          _MethodRow(name: 'context.select<T, R>(f)', desc: '细粒度订阅，但整个 build 都会重建'),
          _MethodRow(name: 'Consumer<T>', desc: 'builder 内局部重建，等价 watch'),
          _MethodRow(name: 'Selector<T, R>', desc: '细粒度 + builder 局部重建，性能最好'),
          SizedBox(height: 12),
          Text(
            '最佳实践：\n'
            '• 简单场景用 watch / select\n'
            '• 按钮回调里用 read\n'
            '• 要限制重建范围用 Consumer / Selector',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String name;
  final String desc;

  const _MethodRow({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 公共组件 =====================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
