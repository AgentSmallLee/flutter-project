import 'package:flutter/material.dart';

// ===================== 数据共享层 =====================

/// 共享数据 Model
class UserInfo {
  final String name;
  final int age;

  UserInfo({required this.name, required this.age});
}

/// 自定义 InheritedWidget：在 widget 树中共享数据
class UserInfoProvider extends InheritedWidget {
  // 需要共享的数据
  final UserInfo userInfo;

  // 修改数据的方法（实际项目中通常配合 ChangeNotifier 或 StatefulWidget 使用）
  final void Function(UserInfo) updateUser;

  const UserInfoProvider({
    super.key,
    required this.userInfo,
    required this.updateUser,
    required super.child,
  });

  /// 提供一个便捷方法，让子 widget 可以通过 context 获取到 UserInfoProvider
  static UserInfoProvider of(BuildContext context) {
    final UserInfoProvider? result =
        context.dependOnInheritedWidgetOfExactType<UserInfoProvider>();
    assert(result != null, 'No UserInfoProvider found in context');
    return result!;
  }

  /// 决定什么时候通知依赖它的子 widget 重建
  @override
  bool updateShouldNotify(UserInfoProvider oldWidget) {
    // 当 userInfo 变化时，通知依赖者刷新
    return userInfo.name != oldWidget.userInfo.name ||
        userInfo.age != oldWidget.userInfo.age;
  }
}

// ===================== 三个层级的子 Widget =====================

/// 顶层子 widget（不直接使用数据，只是中间层）
class MiddleWidget extends StatelessWidget {
  const MiddleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Text('中间层（不读取数据）', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          UserNameWidget(),
          SizedBox(height: 16),
          UserAgeWidget(),
        ],
      ),
    );
  }
}

/// 子 widget A：只读取 name
class UserNameWidget extends StatelessWidget {
  const UserNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    print(context);
    // 通过 of 方法获取共享数据
    final provider = UserInfoProvider.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Text(
        '姓名：${provider.userInfo.name}',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

/// 子 widget B：只读取 age
class UserAgeWidget extends StatelessWidget {
  const UserAgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = UserInfoProvider.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade50,
      child: Text(
        '年龄：${provider.userInfo.age}',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

// ===================== 主页面 =====================

class InheritedWidgetDemo extends StatefulWidget {
  const InheritedWidgetDemo({super.key});

  @override
  State<InheritedWidgetDemo> createState() => _InheritedWidgetDemoState();
}

class _InheritedWidgetDemoState extends State<InheritedWidgetDemo> {
  UserInfo _userInfo = UserInfo(name: '张三', age: 20);

  void _updateName(String newName) {
    setState(() {
      _userInfo = UserInfo(name: newName, age: _userInfo.age);
    });
  }

  void _birthday() {
    setState(() {
      _userInfo = UserInfo(name: _userInfo.name, age: _userInfo.age + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InheritedWidget 演示')),
      // 在根节点放置 Provider，共享给整个子树
      body: UserInfoProvider(
        userInfo: _userInfo,
        updateUser: (user) => setState(() => _userInfo = user),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MiddleWidget(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateName('李四'),
                child: const Text('改名为李四'),
              ),
              ElevatedButton(
                onPressed: _birthday,
                child: const Text('过一次生日（年龄 +1）'),
              ),
              const SizedBox(height: 20),
              const Text(
                '说明：\n'
                '• UserInfoProvider 是 InheritedWidget，放在根节点共享数据\n'
                '• MiddleWidget 不读取数据，只是中间层\n'
                '• UserNameWidget 和 UserAgeWidget 通过 of() 获取数据\n'
                '• 数据变化时，只有依赖它的 widget 会重建',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
