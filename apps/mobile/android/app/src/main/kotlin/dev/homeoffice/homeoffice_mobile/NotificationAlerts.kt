package dev.homeoffice.homeoffice_mobile

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

internal object NotificationAlerts {
    const val CHANNEL = "homeoffice_updates"
    const val EXTRA = "homeoffice.notificationId"
    private val idPattern = Regex("^[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$")
    fun valid(id: String?) = id != null && idPattern.matches(id)

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val channel = NotificationChannel(CHANNEL, context.getString(R.string.notification_channel_name), NotificationManager.IMPORTANCE_HIGH)
            channel.description = context.getString(R.string.notification_channel_description)
            channel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    fun show(context: Context, id: String) {
        if (!valid(id)) return
        if (Build.VERSION.SDK_INT >= 33 && context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        createChannel(context)
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA, id)
            data = android.net.Uri.parse("homeoffice-notification:$id")
        }
        val open = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, CHANNEL) else Notification.Builder(context)
        val notification = builder.setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("HomeOffice")
            .setContentText(context.getString(R.string.notification_body))
            .setContentIntent(open).setAutoCancel(true).setOnlyAlertOnce(true)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setPriority(Notification.PRIORITY_HIGH).setDefaults(Notification.DEFAULT_ALL).build()
        context.getSystemService(NotificationManager::class.java).notify(id, 0, notification)
    }
}
