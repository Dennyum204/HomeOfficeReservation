package dev.homeoffice.homeoffice_mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.installations.FirebaseInstallations

class MainActivity : FlutterActivity() {
    private var registrationChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        // Enabling FID auto-init may wait for Firebase Installations. Flutter's
        // serial background queue keeps this SDK work off Android's UI thread.
        registrationChannel = MethodChannel(messenger, "homeoffice/fcm-registration", StandardMethodCodec.INSTANCE,
            messenger.makeBackgroundTaskQueue()).also { channel ->
            FcmRegistrationEvents.channel = channel
            channel.setMethodCallHandler { call, result ->
                if (call.method != "register" && call.method != "reset") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val messaging = FirebaseMessaging.getInstance()
                    val installations = FirebaseInstallations.getInstance()
                    if (call.method == "register") {
                        // Dart invokes this only after explicit notification consent.
                        messaging.isAutoInitEnabled = true
                        messaging.register().continueWithTask { registration ->
                            if (!registration.isSuccessful) throw registration.exception ?: IllegalStateException()
                            installations.id
                        }.addOnCompleteListener { registration ->
                            if (registration.isSuccessful) result.success(registration.result)
                            else result.error("registration_failed", "FCM registration failed.", registration.exception?.javaClass?.simpleName)
                        }
                    } else {
                        messaging.isAutoInitEnabled = false
                        messaging.unregister().continueWithTask { removal ->
                            if (!removal.isSuccessful) throw removal.exception ?: IllegalStateException()
                            installations.delete()
                        }.addOnCompleteListener { removal ->
                            if (removal.isSuccessful) result.success(null)
                            else result.error("removal_failed", "FCM removal failed.", removal.exception?.javaClass?.simpleName)
                        }
                    }
                } catch (error: Exception) {
                    result.error("configuration_failed", "FCM is unavailable.", error.javaClass.simpleName)
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (FcmRegistrationEvents.channel === registrationChannel) FcmRegistrationEvents.channel = null
        registrationChannel?.setMethodCallHandler(null)
        registrationChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
