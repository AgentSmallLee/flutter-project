import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventChannelPage extends StatefulWidget {
  const EventChannelPage({super.key});

  @override
  State<EventChannelPage> createState() => _EventChannelPageState();
}

class _EventChannelPageState extends State<EventChannelPage> {
  static const _eventChannel =
      EventChannel('com.example.flutter_project/events');

  StreamSubscription<dynamic>? _subscription;
  bool _isListening = false;
  final List<_EventLog> _events = [];
  int _count = 0;

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }

  /// 开始监听事件流
  void _startListening() {
    if (_isListening) return;

    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        setState(() {
          _count++;
          _events.insert(0, _EventLog(
            type: _EventType.data,
            message: '事件 #$_count: $event',
            time: DateTime.now(),
          ));
        });
      },
      onError: (dynamic error) {
        setState(() {
          _count++;
          final platformError = error as PlatformException;
          _events.insert(0, _EventLog(
            type: _EventType.error,
            message:
                '错误 #$_count: [${platformError.code}] ${platformError.message}',
            time: DateTime.now(),
          ));
        });
      },
      onDone: () {
        setState(() {
          _isListening = false;
          _events.insert(0, _EventLog(
            type: _EventType.info,
            message: '事件流已关闭',
            time: DateTime.now(),
          ));
        });
      },
      cancelOnError: false,
    );

    setState(() {
      _isListening = true;
      _events.insert(0, _EventLog(
        type: _EventType.info,
        message: '开始监听事件流...',
        time: DateTime.now(),
      ));
    });
  }

  /// 停止监听
  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() {
    _cancelSubscription();
    setState(() {
      _events.insert(0, _EventLog(
        type: _EventType.info,
        message: '已停止监听',
        time: DateTime.now(),
      ));
    });
  }

  void _clearLogs() {
    setState(() {
      _events.clear();
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventChannel 演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态指示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening ? '正在监听事件流' : '未在监听',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '已收到 $_count 条',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 控制按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? null : _startListening,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始监听'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? _stopListening : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('停止监听'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.delete_outline),
                label: const Text('清空日志'),
              ),
            ),
            const SizedBox(height: 12),

            // 说明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '说明',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• EventChannel 是单向数据流：Android → Flutter\n'
                      '• 点击"开始监听"后，Android 每秒发送一次计数事件\n'
                      '• 每第 5 次发送一个错误事件，演示 onError 处理\n'
                      '• 点击"停止监听"，Android 端定时器会被取消',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 事件日志
            const Text(
              '事件日志',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _events.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无事件',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatTime(event.time),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _getColor(event.type),
                                      fontWeight: event.type ==
                                              _EventType.error
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(_EventType type) {
    switch (type) {
      case _EventType.data:
        return Colors.black87;
      case _EventType.error:
        return Colors.red;
      case _EventType.info:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }
}

enum _EventType { data, error, info }

class _EventLog {
  final _EventType type;
  final String message;
  final DateTime time;

  _EventLog({required this.type, required this.message, required this.time});
}
