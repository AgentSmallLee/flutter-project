package com.example.flutter.flutter_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StringCodec

class MainActivity : FlutterActivity() {

    // Channel 名称必须和 Flutter 端完全一致
    private val CHANNEL = "com.example.flutter_project/message"

    private lateinit var messageChannel: BasicMessageChannel<String>

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 创建 BasicMessageChannel，使用 StringCodec 编解码
        messageChannel = BasicMessageChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
            StringCodec.INSTANCE
        )

        // 注册消息处理器：接收来自 Flutter 的消息并返回回复
        messageChannel.setMessageHandler { message, reply ->
            // 处理来自 Flutter 的消息
            val response = "Android 已收到消息：\"$message\""
            // 回复给 Flutter
            reply.reply(response)

            // 演示：收到 Flutter 消息后，主动向 Flutter 推送一条消息
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                sendMessageToFlutter("这是 Android 主动推送的消息：收到你的 \"$message\" 啦~")
            }, 500)
        }
    }

    /**
     * 主动向 Flutter 端发送消息，并接收 Flutter 的回复
     */
    private fun sendMessageToFlutter(message: String) {
        messageChannel.send(message) { reply ->
            // 这里可以处理 Flutter 端返回的回复
            // reply 即为 Flutter 端 setMessageHandler 中返回的值
            android.util.Log.d("MainActivity", "Flutter 回复: $reply")
        }
    }
}
