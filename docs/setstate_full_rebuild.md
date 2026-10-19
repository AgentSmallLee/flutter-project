# setState 全量重建问题与局部刷新方案

## 问题：setState 会导致整个页面重建

### 现象

在 `StatefulWidget` 中调用 `setState()` 时，整个 `build` 方法会重新执行，**所有子 widget 都会重建**，包括那些数据根本没变的组件（按钮、标题、静态文字等）。

```dart
// ❌ 每次计数变化，整个页面都重建
class _DemoState extends State<Demo> {
  int _count = 0;

  void _increment() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),          // 每次都重建
      body: Column(
        children: [
          Text('$_count'),          // 只有这个需要变
          ElevatedButton(...),      // 每次都重建
          Text('静态说明文字'),      // 每次都重建
        ],
      ),
    );
  }
}
```

### 为什么会这样

`setState` 的作用是把当前 `StatefulWidget` 标记为 dirty，Flutter 会重新调用它的 `build` 方法。它并不知道哪些子 widget 依赖了变化的数据，所以只能全部重建。

> 大多数简单页面全量重建也不会有性能问题，Flutter 的 widget 很轻量。但当子树很重（比如复杂列表、动画、图片）时，局部刷新就很有必要了。

---

## 局部刷新方案对比

| 方案 | 适用场景 | 需要第三方库 | 复杂度 |
|------|---------|-------------|--------|
| `setState` + 拆分成小 `StatefulWidget` | 状态非常局部 | ❌ | 低 |
| `ValueListenableBuilder` | 单个值变化 | ❌ | 低 |
| `ListenableBuilder` / `AnimatedBuilder` | `ChangeNotifier` / `Listenable` | ❌ | 低 |
| `StreamBuilder` | 异步数据流（Stream） | ❌ | 中 |
| `FutureBuilder` | 一次性异步数据（Future） | ❌ | 中 |
| `Provider` / `Riverpod` | 跨页面/复杂状态管理 | ✅ | 中 |

---

## 方案 1：`ValueListenableBuilder`（单个值，最简洁）

适合只有一个值变化的场景，用 `ValueNotifier` 持有数据：

```dart
final _count = ValueNotifier<int>(0);

// ...

ValueListenableBuilder<int>(
  valueListenable: _count,
  builder: (context, value, child) {
    return Text('$value', style: TextStyle(fontSize: 48));
  },
)

// 修改数据
_count.value++;
```

- `builder` 只有在 `value` 变化时才会调用
- `child` 参数可以传入不需要重建的子 widget（可选优化）

---

## 方案 2：`ListenableBuilder`（ChangeNotifier，最推荐）

当你已经在用 `ChangeNotifier`（比如自定义 Model、Animation 等）时，用 `ListenableBuilder` 最方便。它和 `AnimatedBuilder` 本质是同一个东西。

```dart
final CounterModel _counter = CounterModel(); // 继承 ChangeNotifier

// ...

ListenableBuilder(
  listenable: _counter,
  builder: (context, child) {
    return Text('${_counter.count}');
  },
)
```

**优点：**
- 不需要手动 `addListener` / `removeListener`
- 不需要 `setState`
- 只有 `builder` 里的内容会重建
- 纯 Flutter SDK，无第三方依赖

---

## 方案 3：拆分成独立的 `StatefulWidget`

把需要刷新的部分提取成独立的 StatefulWidget，让它自己管理状态：

```dart
class CounterText extends StatefulWidget {
  const CounterText({super.key});

  @override
  State<CounterText> createState() => _CounterTextState();
}

class _CounterTextState extends State<CounterText> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Text('$_count');
  }

  void increment() => setState(() => _count++);
}
```

这样父级重建不会影响它。但缺点是如果父级需要触发它变化，得用 `GlobalKey` 或回调，比较繁琐。

---

## 方案 4：`StreamBuilder`

适合异步流式数据：

```dart
StreamBuilder<int>(
  stream: _counterStream,
  builder: (context, snapshot) {
    return Text('${snapshot.data ?? 0}');
  },
)
```

---

## 方案 5：Provider / Riverpod（工程化方案）

对于中大型项目，推荐用 Provider 或 Riverpod，它们底层也是基于 InheritedWidget + Listenable 实现局部刷新：

```dart
// Provider 写法
Consumer(
  builder: (context, ref, child) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  },
)
```

只有 `Consumer` 包裹的部分会重建。

---

## 最佳实践建议

1. **简单页面**：直接 `setState` 就行，不用过度优化
2. **单个值变化**：用 `ValueNotifier` + `ValueListenableBuilder`
3. **已有 ChangeNotifier**：用 `ListenableBuilder`
4. **跨组件/跨页面共享状态**：用 Provider / Riverpod / Bloc
5. **优化思路**：把 `builder` 尽量缩小，只包裹真正依赖数据的那部分 widget
