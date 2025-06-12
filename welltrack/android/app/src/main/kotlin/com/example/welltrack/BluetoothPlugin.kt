package com.example.welltrack

import android.bluetooth.BluetoothAdapter
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class BluetoothPlugin {
    companion object {
        private const val CHANNEL = "com.welltrack/bluetooth"
        
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBluetoothMacAddress" -> {
                        try {
                            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                            val macAddress = bluetoothAdapter?.address
                            
                            if (macAddress != null && macAddress != "02:00:00:00:00:00") {
                                // Valid MAC address
                                result.success(macAddress)
                            } else {
                                // MAC address not available or is the default dummy address
                                result.success(null)
                            }
                        } catch (e: Exception) {
                            result.error("BLUETOOTH_ERROR", "Failed to get Bluetooth MAC address", e.message)
                        }
                    }
                    "setDeviceName" -> {
                        try {
                            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                            val name = call.argument<String>("name")
                            
                            if (bluetoothAdapter != null && name != null) {
                                bluetoothAdapter.name = name
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.error("BLUETOOTH_ERROR", "Failed to set device name", e.message)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }
}