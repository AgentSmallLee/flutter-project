import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelPage extends StatefulWidget {
  const MethodChannelPage({super.key});

  @override
  State<MethodChannelPage> createState() => _MethodChannelPageState();
}

class _MethodChannelPageState extends State<MethodChannelPage> {
  static const _channel = MethodChannel('com.example.flutter_project/method');

  final _aController = TextEditingController(text: '12');
  final _bController = TextEditingController(text: '7');

  String _batteryLevel = '未知';
  String _addResult = '';
  String _deviceInfo = '';
  String _log = '';

  // Android 反向调用 Flutter 的计数器
  int _reverseCounter = 0;
  bool _reverseCounterRunning = false;

  @override
  void initState() {
    super.initState();
    // 注册 MethodCallHandler，处理 Android 端反向调用的方法
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    // 页面销毁时停止计数器
    if (_reverseCounterRunning) {
      _channel.invokeMethod('stopCounter');
    }
    super.dispose();
  }

  /// 处理来自 Android 端的反向方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCount':
        final count = call.arguments as int? ?? 0;
        setState(() {
          _reverseCounter = count;
        });
        _appendLog('[收到] Android 调用 onCount($count) → 返回 "收到第 $count 次"');
        // 返回值会被 Android 端接收
        return '收到第 $count 次';
      case 'onCounterStopped':
        setState(() {
          _reverseCounterRunning = false;
        });
        _appendLog('[收到] Android 调用 onCounterStopped');
        return 'ok';
      default:
        throw MissingPluginException();
    }
  }

  void _appendLog(String msg) {
    setState(() {
      _log = '$msg\n$_log';
    });
  }

  /// 调用 Android 端的 getBatteryLevel 方法
  Future<void> _getBatteryLevel() async {
    try {
      final int level = await _channel.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryLevel = '$level%';
      });
      _appendLog('[成功] getBatteryLevel → $level%');
    } on PlatformException catch (e) {
      setState(() {
        _batteryLevel = '错误: ${e.message}';
      });
      _appendLog('[错误] getBatteryLevel: ${e.code} - ${e.message}');
    }
  }

  /// 调用 Android 端的 add 方法，带参数
  Future<void> _add() async {
    try {
      final a = int.tryParse(_aController.text) ?? 0;
      final b = int.tryParse(_bController.text) ?? 0;
      final int result = await _channel.invokeMethod(
        'add',
        {'a': a, 'b': b},
      );
      setState(() {
        _addResult = '$a + $b = $result';
      });
      _appendLog('[成功] add($a, $b) → $result');
    } on PlatformException catch (e) {
      setState(() {
        _addResult = '错误: ${e.message}';
      });
      _appendLog('[错误] add: ${e.code} - ${e.message}');
    }
  }

  /// 调用 Android 端的 getDeviceInfo 方法，返回 Map
  Future<void> _getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> info =
          await _channel.invokeMethod('getDeviceInfo');
      setState(() {
        _deviceInfo = info.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n');
      });
      _appendLog('[成功] getDeviceInfo → ${info.length} 项');
    } on PlatformException catch (e) {
      setState(() {
        _deviceInfo = '错误: ${e.message}';
      });
      _appendLog('[错误] getDeviceInfo: ${e.code} - ${e.message}');
    }
  }

  /// 启动 Android 端的反向计数器
  Future<void> _startReverseCounter() async {
    try {
      await _channel.invokeMethod('startCounter');
      setState(() {
        _reverseCounterRunning = true;
        _reverseCounter = 0;
      });
      _appendLog('[调用] startCounter → 等待 Android 反向调用 onCount');
    } on PlatformException catch (e) {
      _appendLog('[错误] startCounter: ${e.code} - ${e.message}');
    }
  }

  /// 停止 Android 端的反向计数器
  Future<void> _stopReverseCounter() async {
    try {
      await _channel.invokeMethod('stopCounter');
      setState(() {
        _reverseCounterRunning = false;
      });
      _appendLog('[调用] stopCounter');
    } on PlatformException catch (e) {
      _appendLog('[错误] stopCounter: ${e.code} - ${e.message}');
    }
  }

  /// 调用一个不存在的方法，演示 MissingPluginException
  Future<void> _callUnknownMethod() async {
    try {
      await _channel.invokeMethod('nonExistentMethod');
      _appendLog('[意外] 未知方法居然成功了');
    } on MissingPluginException catch (e) {
      _appendLog('[异常] MissingPluginException: ${e.message}');
    } on PlatformException catch (e) {
      _appendLog('[错误] ${e.code} - ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MethodChannel 演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 获取电量
              _buildCard(
                title: '1. 获取电量',
                children: [
                  Text('当前电量：$_batteryLevel'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _getBatteryLevel,
                    child: const Text('调用 getBatteryLevel'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 加法计算（带参数）
              _buildCard(
                title: '2. 加法计算（传参）',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _aController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'a',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('+', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _bController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'b',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _add,
                    child: const Text('调用 add(a, b)'),
                  ),
                  const SizedBox(height: 8),
                  Text('结果：$_addResult'),
                ],
              ),
              const SizedBox(height: 12),

              // 获取设备信息（返回 Map）
              _buildCard(
                title: '3. 获取设备信息（返回 Map）',
                children: [
                  ElevatedButton(
                    onPressed: _getDeviceInfo,
                    child: const Text('调用 getDeviceInfo'),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _deviceInfo.isEmpty ? '未获取' : _deviceInfo,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Android 反向调用 Flutter
              _buildCard(
                title: '4. Android 反向调用 Flutter',
                children: [
                  Row(
                    children: [
                      const Text('当前计数：'),
                      Text(
                        '$_reverseCounter',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _reverseCounterRunning
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _reverseCounterRunning
                              ? null
                              : _startReverseCounter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('开始计数'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _reverseCounterRunning
                              ? _stopReverseCounter
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('停止计数'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Flutter 调用 startCounter → Android 每秒反向调用 Flutter 的 onCount 方法',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 调用不存在的方法
              _buildCard(
                title: '5. 异常演示',
                children: [
                  OutlinedButton(
                    onPressed: _callUnknownMethod,
                    child: const Text('调用不存在的方法'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '演示 MissingPluginException / 错误处理',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 调用日志
              const Text(
                '调用日志',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _log.isEmpty ? '暂无调用...' : _log,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
