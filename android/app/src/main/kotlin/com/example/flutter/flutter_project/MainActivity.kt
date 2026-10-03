package com.example.flutter.flutter_project

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StringCodec

class MainActivity : FlutterActivity() {

    // BasicMessageChannel 名称
    private val MESSAGE_CHANNEL = "com.example.flutter_project/message"
    // EventChannel 名称
    private val EVENT_CHANNEL = "com.example.flutter_project/events"

    private lateinit var messageChannel: BasicMessageChannel<String>

    // EventChannel 相关
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var counter = 0
    private var isRunning = false

    // 定时任务：每秒发送一次事件
    private val eventRunnable = object : Runnable {
        override fun run() {
            if (!isRunning) return
            counter++

            // 每第 5 次发送一个错误事件，演示 error 处理
            if (counter % 5 == 0) {
                eventSink?.error(
                    "DEMO_ERROR",
                    "第 $counter 次事件模拟错误",
                    "这是一个演示用的错误详情"
                )
            } else {
                eventSink?.success("计数事件: $counter")
            }

            handler.postDelayed(this, 1000)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ====== BasicMessageChannel ======
        messageChannel = BasicMessageChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MESSAGE_CHANNEL,
            StringCodec.INSTANCE
        )

        messageChannel.setMessageHandler { message, reply ->
            val response = "Android 已收到消息：\"$message\""
            reply.reply(response)

            // 演示：收到 Flutter 消息后，主动向 Flutter 推送一条消息
            handler.postDelayed({
                sendMessageToFlutter("这是 Android 主动推送的消息：收到你的 \"$message\" 啦~")
            }, 500)
        }

        // ====== EventChannel ======
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // Flutter 端开始监听
                eventSink = events
                counter = 0
                isRunning = true
                handler.post(eventRunnable)
            }

            override fun onCancel(arguments: Any?) {
                // Flutter 端取消监听
                isRunning = false
                handler.removeCallbacks(eventRunnable)
                eventSink = null
            }
        })
    }

    /**
     * 主动向 Flutter 端发送消息，并接收 Flutter 的回复
     */
    private fun sendMessageToFlutter(message: String) {
        messageChannel.send(message) { reply ->
            android.util.Log.d("MainActivity", "Flutter 回复: $reply")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // 页面销毁时清理资源
        isRunning = false
        handler.removeCallbacks(eventRunnable)
    }
}
