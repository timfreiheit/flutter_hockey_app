package de.timfreiheit.flutterhockeyapp

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import net.hockeyapp.android.CrashManager
import net.hockeyapp.android.ExceptionHandler
import net.hockeyapp.android.UpdateManager
import java.io.PrintStream

class FlutterHockeyAppPlugin(
        private val registrar: Registrar
) : MethodCallHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_hockey_app")
            channel.setMethodCallHandler(FlutterHockeyAppPlugin(registrar))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                init(call.argument("appId"), call.argument("updateEnabled"))
                result.success(null)
            }
            "captureException" -> {
                captureException(call.argument("exception"), call.argument("stacktrace"))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun init(appId: String, updateEnabled: Boolean) {
        CrashManager.register(registrar.context(), appId, null)
        if (updateEnabled) {
            UpdateManager.register(registrar.activity())
        }
    }

    private fun captureException(exception: Map<String, String>, stacktrace: String) {
        val type = exception["type"] ?: "UNKNOWN"
        val message = exception["value"] ?: "UNKNOWN"

        ExceptionHandler.saveNativeException(
                FlutterException(type, message),
                "$type: $message\n$stacktrace",
                Thread.currentThread(),
                null
        )
    }
}

private class FlutterException(
        type: String,
        message: String
) : Exception("$type: $message") {
    init {
        stackTrace =  arrayOf()
    }

    override fun toString(): String {
        return message ?: ""
    }
}
