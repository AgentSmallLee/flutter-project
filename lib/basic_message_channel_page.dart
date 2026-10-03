import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasicMessageChannelPage extends StatefulWidget {
  const BasicMessageChannelPage({super.key});

  @override
  State<BasicMessageChannelPage> createState() =>
      _BasicMessageChannelPageState();
}

class _BasicMessageChannelPageState extends State<BasicMessageChannelPage> {
  // 定义 BasicMessageChannel，channel 名称要和 Android 端保持一致
  static const _channel = BasicMessageChannel<String>(
    'com.example.flutter_project/message',
    StringCodec(),
  );

  // 记录从 Android 端收到的消息
  String _receivedFromAndroid = '还未收到 Android 的消息';
  // 记录发送给 Android 后收到的回复
  String _replyFromAndroid = '';
  // 文本输入控制器
  final _controller = TextEditingController(text: 'Hello from Flutter!');
  // 消息日志
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    // 注册消息处理器，接收来自 Android 端的消息
    _channel.setMessageHandler(_handleMessageFromAndroid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 处理来自 Android 端的消息，并返回回复
  Future<String> _handleMessageFromAndroid(String? message) async {
    setState(() {
      _receivedFromAndroid = message ?? '(空消息)';
      _logs.insert(0, '[收到] Android → Flutter: $message');
    });
    // 返回给 Android 端的回复
    return 'Flutter 已收到消息："$message"';
  }

  /// 向 Android 端发送消息，并等待回复
  Future<void> _sendMessageToAndroid() async {
    final message = _controller.text;
    setState(() {
      _logs.insert(0, '[发送] Flutter → Android: $message');
    });
    try {
      final String? reply = await _channel.send(message);
      setState(() {
        _replyFromAndroid = reply ?? '(空回复)';
        _logs.insert(0, '[回复] Android → Flutter: $reply');
      });
    } on PlatformException catch (e) {
      setState(() {
        _replyFromAndroid = '错误: ${e.message}';
        _logs.insert(0, '[错误] ${e.message}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BasicMessageChannel 演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 发送消息区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Flutter → Android 发送消息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '输入消息内容',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _sendMessageToAndroid,
                      child: const Text('发送给 Android'),
                    ),
                    const SizedBox(height: 8),
                    Text('Android 回复：$_replyFromAndroid'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 接收消息区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. Android → Flutter 接收消息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('最新消息：$_receivedFromAndroid'),
                    const SizedBox(height: 4),
                    const Text(
                      '（Android 端在收到 Flutter 消息后会主动推送一条）',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 消息日志
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3. 消息日志',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _logs.isEmpty
                            ? const Text(
                                '暂无消息记录',
                                style: TextStyle(color: Colors.grey),
                              )
                            : ListView.builder(
                                reverse: true,
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(
                                      _logs[index],
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
