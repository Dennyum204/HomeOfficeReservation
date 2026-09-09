package dev.homeoffice.homeoffice_mobile

import android.os.Handler
import android.os.Looper
import com.google.firebase.messaging.FirebaseMessagingService
import io.flutter.plugin.common.MethodChannel

internal object FcmRegistrationEvents {
    @Volatile var channel: MethodChannel? = null
    private val main = Handler(Looper.getMainLooper())

    fun registered(installationId: String) {
        // Native callbacks may run on a worker thread. Flutter messages require main.
        // If the UI is absent, foreground synchronization retrieves the current FID.
        main.post { channel?.invokeMethod("registered", installationId) }
    }
}

class FcmRegistrationService : FirebaseMessagingService() {
    override fun onRegistered(installationId: String) {
        FcmRegistrationEvents.registered(installationId)
    }
    // FlutterFire's protected receiver still handles message display/opening.
    // Do not also forward onMessageReceived and deliver every message twice.
}
