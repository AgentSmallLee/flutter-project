package com.example.flutter.flutter_project

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StringCodec

class MainActivity : FlutterActivity() {

    // BasicMessageChannel 名称
    private val MESSAGE_CHANNEL = "com.example.flutter_project/message"
    // EventChannel 名称
    private val EVENT_CHANNEL = "com.example.flutter_project/events"
    // MethodChannel 名称
    private val METHOD_CHANNEL = "com.example.flutter_project/method"

    private lateinit var messageChannel: BasicMessageChannel<String>
    private lateinit var methodChannel: MethodChannel

    // EventChannel 相关
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var counter = 0
    private var isRunning = false

    // MethodChannel 反向调用相关
    private var reverseCounter = 0
    private var reverseRunning = false
    private val reverseRunnable = object : Runnable {
        override fun run() {
            if (!reverseRunning) return
            reverseCounter++
            // 反向调用 Flutter 端的 onCount 方法
            methodChannel.invokeMethod(
                "onCount",
                reverseCounter,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        android.util.Log.d(
                            "MainActivity",
                            "Flutter onCount 返回: $result"
                        )
                    }
                    override fun error(
                        errorCode: String,
                        errorMessage: String?,
                        errorDetails: Any?
                    ) {
                        android.util.Log.e(
                            "MainActivity",
                            "onCount 错误: $errorCode - $errorMessage"
                        )
                    }
                    override fun notImplemented() {
                        android.util.Log.w(
                            "MainActivity",
                            "onCount 未实现"
                        )
                    }
                }
            )
            handler.postDelayed(this, 1000)
        }
    }

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

        // ====== MethodChannel ======
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        )
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val level = getBatteryLevel()
                    if (level != -1) {
                        result.success(level)
                    } else {
                        result.error(
                            "UNAVAILABLE",
                            "电量信息不可用",
                            null
                        )
                    }
                }
                "add" -> {
                    val a = call.argument<Int>("a") ?: 0
                    val b = call.argument<Int>("b") ?: 0
                    result.success(a + b)
                }
                "getDeviceInfo" -> {
                    val info = mapOf(
                        "model" to Build.MODEL,
                        "brand" to Build.BRAND,
                        "androidVersion" to Build.VERSION.RELEASE,
                        "sdkInt" to Build.VERSION.SDK_INT,
                        "device" to Build.DEVICE,
                        "manufacturer" to Build.MANUFACTURER
                    )
                    result.success(info)
                }
                "startCounter" -> {
                    startReverseCounter()
                    result.success(null)
                }
                "stopCounter" -> {
                    stopReverseCounter()
                    // 通知 Flutter 端已停止
                    methodChannel.invokeMethod("onCounterStopped", null)
                    result.success(null)
                }
                else -> {
                    // 未实现的方法返回 notImplemented
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * 获取当前电池电量百分比
     */
    private fun getBatteryLevel(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE)
                    as android.os.BatteryManager
            batteryManager.getIntProperty(
                android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY
            )
        } else {
            -1
        }
    }

    /**
     * 启动反向计数器：Android 每秒调用一次 Flutter 的 onCount 方法
     */
    private fun startReverseCounter() {
        if (reverseRunning) return
        reverseCounter = 0
        reverseRunning = true
        handler.post(reverseRunnable)
    }

    /**
     * 停止反向计数器
     */
    private fun stopReverseCounter() {
        reverseRunning = false
        handler.removeCallbacks(reverseRunnable)
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
        reverseRunning = false
        handler.removeCallbacks(reverseRunnable)
    }
}
