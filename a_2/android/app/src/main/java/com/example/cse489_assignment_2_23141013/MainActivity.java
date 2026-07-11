package com.example.cse489_assignment_2_23141013;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL =
            "cse489_assignment_2_23141013/broadcast";

    private static final String CUSTOM_ACTION =
            "com.example.cse489_assignment_2_23141013.CUSTOM_MESSAGE";

    private static final String MESSAGE_KEY = "message";

    private BroadcastReceiver customBroadcastReceiver;
    private BroadcastReceiver batteryBroadcastReceiver;

    @Override
    public void configureFlutterEngine(
            @NonNull FlutterEngine flutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            if (call.method.equals("sendCustomBroadcast")) {

                String message = call.argument("message");

                if (message == null || message.trim().isEmpty()) {
                    result.error(
                            "EMPTY_MESSAGE",
                            "Please enter a message.",
                            null
                    );
                    return;
                }

                sendCustomBroadcast(message, result);

            } else if (call.method.equals("getBatteryPercentage")) {

                receiveBatteryPercentage(result);

            } else {

                result.notImplemented();
            }
        });
    }

    private void sendCustomBroadcast(
            String message,
            MethodChannel.Result result
    ) {
        unregisterCustomReceiver();

        customBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                if (!CUSTOM_ACTION.equals(intent.getAction())) {
                    return;
                }

                String receivedMessage =
                        intent.getStringExtra(MESSAGE_KEY);

                unregisterCustomReceiver();

                if (receivedMessage == null) {
                    receivedMessage = "";
                }

                result.success(receivedMessage);
            }
        };

        IntentFilter filter = new IntentFilter(CUSTOM_ACTION);

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(
                        customBroadcastReceiver,
                        filter,
                        Context.RECEIVER_NOT_EXPORTED
                );
            } else {
                registerReceiver(
                        customBroadcastReceiver,
                        filter
                );
            }

            Intent broadcastIntent = new Intent(CUSTOM_ACTION);

            broadcastIntent.setPackage(getPackageName());

            broadcastIntent.putExtra(
                    MESSAGE_KEY,
                    message
            );

            sendBroadcast(broadcastIntent);

        } catch (Exception exception) {
            unregisterCustomReceiver();

            result.error(
                    "CUSTOM_BROADCAST_ERROR",
                    exception.toString(),
                    null
            );
        }
    }

    private void receiveBatteryPercentage(
            MethodChannel.Result result
    ) {
        unregisterBatteryReceiver();

        batteryBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                if (!Intent.ACTION_BATTERY_CHANGED.equals(
                        intent.getAction()
                )) {
                    return;
                }

                int level = intent.getIntExtra(
                        BatteryManager.EXTRA_LEVEL,
                        -1
                );

                int scale = intent.getIntExtra(
                        BatteryManager.EXTRA_SCALE,
                        -1
                );

                unregisterBatteryReceiver();

                if (level < 0 || scale <= 0) {
                    result.error(
                            "BATTERY_ERROR",
                            "Battery percentage could not be received.",
                            null
                    );
                    return;
                }

                int percentage = Math.round(
                        (level * 100.0f) / scale
                );

                result.success(percentage);
            }
        };

        IntentFilter filter =
                new IntentFilter(Intent.ACTION_BATTERY_CHANGED);

        try {
            registerReceiver(
                    batteryBroadcastReceiver,
                    filter
            );

        } catch (Exception exception) {
            unregisterBatteryReceiver();

            result.error(
                    "BATTERY_ERROR",
                    exception.toString(),
                    null
            );
        }
    }

    private void unregisterCustomReceiver() {
        if (customBroadcastReceiver == null) {
            return;
        }

        try {
            unregisterReceiver(customBroadcastReceiver);
        } catch (IllegalArgumentException ignored) {
        }

        customBroadcastReceiver = null;
    }

    private void unregisterBatteryReceiver() {
        if (batteryBroadcastReceiver == null) {
            return;
        }

        try {
            unregisterReceiver(batteryBroadcastReceiver);
        } catch (IllegalArgumentException ignored) {
        }

        batteryBroadcastReceiver = null;
    }

    @Override
    protected void onDestroy() {
        unregisterCustomReceiver();
        unregisterBatteryReceiver();
        super.onDestroy();
    }
}