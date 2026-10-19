# No Directionality widget found 报错解决方案

## 报错信息

```
No Directionality widget found.

RichText widgets require a Directionality widget ancestor.
```

通常伴随着 `Text` → `RichText` 的 widget 链，说明使用了 `Text` widget 但缺少文本方向配置。

---

## 根本原因

Flutter 中的 `Text` widget 底层依赖 `RichText` 来渲染文字，而 `RichText` **必须**知道文本的阅读方向（从左到右 LTR 还是从右到左 RTL），这个方向信息由 `Directionality` widget 提供。

正常情况下，`MaterialApp` 会自动注入 `Directionality`，所以不会遇到这个问题。只有当 `Text` 出现在 `MaterialApp` 之外时才会报错。

**常见触发场景：**

1. `runApp()` 直接传入一个只有 `Text` 的 widget，没有包裹 `MaterialApp` / `WidgetsApp`
2. 在 `Overlay`、`OverlayEntry` 或 `navigator.overlay` 中直接放入 `Text`
3. 使用 `showDialog` / `showModalBottomSheet` 等方法时，context 不在 `MaterialApp` 树下

---

## 解决方案

### 方案一：用 `MaterialApp` 包裹根节点（推荐）

```dart
void main() {
  runApp(
    MaterialApp(
      home: MyPage(),
    ),
  );
}
```

`MaterialApp` 自动提供 `Directionality`、`Theme`、`Navigator`、`Localizations` 等，是标准做法。

### 方案二：用 `Directionality` 包裹（最轻量）

如果你不想引入 Material 设计（比如纯 UI 组件库、非 Material 应用），可以直接提供方向：

```dart
runApp(
  Directionality(
    textDirection: TextDirection.ltr, // 或 TextDirection.rtl
    child: MyPage(),
  ),
);
```

### 方案三：用 `WidgetsApp` 包裹

介于 `Directionality` 和 `MaterialApp` 之间，提供导航等基础能力但不带 Material 样式：

```dart
runApp(
  WidgetsApp(
    color: Colors.blue,
    builder: (context, child) => MyPage(),
  ),
);
```

### 方案四：Overlay / Dialog 场景

如果是在 `OverlayEntry` 中遇到，给内容套一层 `Directionality` 或 `Material`：

```dart
OverlayEntry(
  builder: (context) => Material(
    child: Text('Hello'),
  ),
)
```

---

## 延伸：文字出现黄色双下划线

相关但不同的问题：`Text` 显示为带下划线的黄色文本。

- **原因：** 缺少 `DefaultTextStyle`（通常由 `Material` / `Scaffold` 提供），`Text` 使用了 debug 模式下的 fallback 样式。
- **解决：** 用 `Scaffold` 或 `Material` 包裹，或手动设置 `style: TextStyle(decoration: TextDecoration.none)`。

---

## 小结

| 方案 | 适用场景 | 额外提供 |
|------|----------|----------|
| `MaterialApp` | 标准 Flutter 应用 | Theme、Navigator、Localizations 等 |
| `Directionality` | 最简场景、自定义框架 | 仅文本方向 |
| `WidgetsApp` | 非 Material 应用 | Navigator、焦点管理等基础能力 |
| `Scaffold` / `Material` | 页面内部、Overlay 中 | 默认文本样式、墨水效果等 |

**建议：** 绝大多数情况下直接用 `MaterialApp` 作为根节点即可。
