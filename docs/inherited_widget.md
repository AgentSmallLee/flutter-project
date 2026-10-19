# InheritedWidget 详解

## 什么是 InheritedWidget

`InheritedWidget` 是 Flutter 中的一个特殊 widget，它的作用是**在 widget 树中向下共享数据**。子 widget 可以通过 `context` 找到上层最近的某个 `InheritedWidget`，获取它里面的数据。

它是 Flutter 状态管理的**基石**，`Theme`、`MediaQuery`、`Navigator`、`Provider`、`Riverpod` 等都是基于它（或类似机制）实现的。

---

## 作用

### 1. 跨层级数据共享，避免层层传递

没有 InheritedWidget 时，数据要从顶层逐层通过构造函数传到最底层：

```
顶层 Widget → 中间层 Widget → 底层 Widget（构造函数传参数）
```

有了 InheritedWidget 后，数据放在顶层，底层直接取：

```
顶层 InheritedWidget（存放数据）
    ↓
  中间层 Widget（什么都不用做）
    ↓
  底层 Widget（通过 context 直接拿数据）
```

中间层不需要感知数据的存在，大大简化了代码。

### 2. 数据变化时，自动通知依赖它的 widget 重建

当 `InheritedWidget` 的数据变化时（父组件 `setState` 替换了它），Flutter 会自动通知所有**依赖**它的子 widget 调用 `build` 方法，实现局部刷新。

---

## 核心 API

### 1. `dependOnInheritedWidgetOfExactType<T>()`

子 widget 通过这个方法**订阅** InheritedWidget。订阅后，当 InheritedWidget 变化时，子 widget 会自动重建。

```dart
final provider = context.dependOnInheritedWidgetOfExactType<MyProvider>();
```

### 2. `getElementForInheritedWidgetOfExactType<T>()`

只获取 InheritedWidget，但**不订阅**。变化时不会重建。适合只需要在点击事件里拿一下数据的场景。

```dart
final provider = context
    .getElementForInheritedWidgetOfExactType<MyProvider>()
    ?.widget as MyProvider;
```

### 3. `updateShouldNotify(oldWidget)`

判断数据是否发生了变化，返回 `true` 时才会通知依赖者重建。如果返回 `false`，即使 InheritedWidget 被重建了，子 widget 也不会跟着刷新。

```dart
@override
bool updateShouldNotify(MyProvider oldWidget) {
  return data != oldWidget.data;
}
```

---

## 使用步骤

### 第一步：定义 InheritedWidget

```dart
class MyDataProvider extends InheritedWidget {
  final MyData data;

  const MyDataProvider({
    super.key,
    required this.data,
    required super.child,
  });

  // 便捷获取方法
  static MyDataProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyDataProvider>()!;
  }

  @override
  bool updateShouldNotify(MyDataProvider oldWidget) {
    return data != oldWidget.data;
  }
}
```

### 第二步：在 widget 树中放置它

通常放在需要共享数据的子树的根节点：

```dart
MyDataProvider(
  data: myData,
  child: SomeSubtree(), // 这个子树里的所有 widget 都能访问到 data
)
```

### 第三步：在子 widget 中使用

```dart
class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = MyDataProvider.of(context).data;
    return Text('$data');
  }
}
```

---

## 使用场景

### ✅ 适合的场景

1. **全局主题配置** — 如 `Theme.of(context)`、`MediaQuery.of(context)`
2. **全局用户信息** — 登录用户信息在多个页面共享
3. **App 级配置** — 语言、主题模式（暗黑/亮色）等
4. **页面级状态共享** — 一个复杂页面内多个子组件共享同一份数据
5. **作为更高级状态管理的基础** — Provider、Riverpod、Bloc 等都基于此

### ❌ 不适合的场景

1. **局部小状态** — 组件自己的状态直接用 `setState` 就行
2. **复杂的业务逻辑** — 纯 InheritedWidget 数据是不可变的，修改需要靠外部 `StatefulWidget`，复杂场景建议用 Provider / Bloc
3. **频繁变化的数据且只有少数组件关心** — 可以用 ValueListenable 等更轻量的方案

---

## 注意事项

### 1. InheritedWidget 本身是不可变的

`InheritedWidget` 的数据是 `final` 的，它不能自己改自己。要修改数据，需要靠父级的 `StatefulWidget` 调用 `setState` 来重建一个新的 `InheritedWidget`。

```dart
// 父级 State 中
setState(() {
  _data = newData; // 重建时生成新的 InheritedWidget
});
```

### 2. `of` 方法的两种写法

- **订阅模式**（`dependOn`）：数据变化时会重建，适合在 `build` 方法中使用
- **非订阅模式**（`getElementFor`）：只拿数据不订阅，适合在点击事件、`initState` 等非 build 时机使用

### 3. 不要在 `initState` 中用 `dependOnInheritedWidgetOfExactType`

`initState` 中不能依赖 InheritedWidget（会报错）。如果需要在初始化时读取数据，用 `getElementForInheritedWidgetOfExactType`，或者在 `didChangeDependencies` 中使用。

### 4. 性能考虑

`dependOn` 会让整个依赖 widget 重建。如果 widget 很大，可以用 `Builder` 缩小重建范围，或者使用 `getElementFor` 手动控制。

---

## 与其他方案对比

| 方案 | 数据方向 | 是否自动刷新 | 适用场景 |
|------|---------|-------------|---------|
| 构造函数传值 | 自上而下 | ❌ | 父子之间简单传值 |
| InheritedWidget | 自上而下 | ✅ | 跨层级共享数据 |
| ChangeNotifier | 订阅通知 | ✅ | 观察者模式，数据变化主动通知 |
| Provider | 自上而下 | ✅ | InheritedWidget + ChangeNotifier 的封装 |
| Stream | 单向流 | ✅ | 异步数据流 |

---

## 实际例子

Flutter SDK 中到处都是 InheritedWidget 的身影：

- `Theme.of(context)` — 获取主题
- `MediaQuery.of(context)` — 获取屏幕尺寸、方向等
- `Navigator.of(context)` — 获取导航器
- `Scaffold.of(context)` — 获取 Scaffold 状态（如打开 Drawer）
- `DefaultTextStyle.of(context)` — 获取默认文本样式

你每天都在用到它，只是可能没意识到。
