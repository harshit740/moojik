package com.moojik.moojik

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.JobIntentService
import androidx.core.app.NotificationManagerCompat
import com.github.kiulian.downloader.OnYoutubeDownloadListener
import com.github.kiulian.downloader.YoutubeDownloader
import com.moojik.moojik.MainActivity.Companion.CHANNEL
import com.moojik.moojik.MainActivity.Companion.flutterEngineInstance
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.util.PathUtils
import java.io.File
import java.io.IOException


class DownloadService : JobIntentService() {
    companion object {
        lateinit var channel: MethodChannel
        var downloadQueue = ArrayList<HashMap<String, Boolean>>()
        var JobId = 1001
        fun enQueueDownload(context: Context, intent: Intent) {
            val youtubeUrl = intent.getStringExtra("youtubeUrl")
            if (downloadQueue.isNotEmpty()) {
                downloadQueue.forEach {
                    if (it.containsKey(youtubeUrl)) return
                }
            }
            val value = HashMap<String, Boolean>()
            value[youtubeUrl] = true
            downloadQueue.add(value)
            enqueueWork(context, DownloadService::class.java, JobId, intent)
        }
    }

    private lateinit var moojikDatabase: SQLiteDatabase
    private lateinit var file: File
    private lateinit var outDir: File
    private lateinit var builder: Notification.Builder
    private lateinit var notification: Notification

    override fun onCreate() {
        channel = MethodChannel(flutterEngineInstance.dartExecutor.binaryMessenger, CHANNEL)
        try {
            outDir = File(PathUtils.getDataDirectory(this), "/Moojik/")
            file = File(PathUtils.getDataDirectory(this), "MoojkFlux.db")
            moojikDatabase = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READWRITE)
            Log.d("DownloadService", "DownloadService Started")
            createNotificationChannel()
            if (!outDir.exists()) {
                val mkdirs = outDir.mkdirs()
                if (!mkdirs) throw IOException("Could not create output directory: ${outDir.absolutePath}")
            }
        } catch (e: Exception) {
            moojikDatabase.close()
        }
        super.onCreate()
    }

    override fun onHandleWork(intent: Intent) {

        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentTitle("Starting")
            builder.setOngoing(true)
            notify(2, builder.build())
        }
        val youtubeUrl = intent.getStringExtra("youtubeUrl")
        val video = YoutubeDownloader().getVideo(youtubeUrl)
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentTitle(video.details().title())
            builder.setOngoing(true)
            notify(2, builder.build())
        }
        video.downloadAsync(video.audioFormats().run { this[this.size - 1] }, outDir, youtubeUrl, object : OnYoutubeDownloadListener {
            override fun onDownloading(progress: Int) {
                downloadQueue.forEachIndexed { index, hashMap ->
                    if (hashMap.containsKey(youtubeUrl)) {
                        downloadQueue[index][youtubeUrl] = false
                    }
                }
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Downloading...")
                            .setProgress(100, progress, false)
                    builder.setOngoing(true)
                    notify(2, builder.build())
                }
            }

            override fun onFinished(file: File) {
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Download Complete")
                    builder.setProgress(0, 0, false)
                    builder.setOngoing(false)
                    notify(2, builder.build())
                    builder.setAutoCancel(true)
                }
                updateDb(youtubeUrl, file.absolutePath, video.details().thumbnails().run { this[this.size - 1] }.toString())
            }

            override fun onError(throwable: Throwable?) {
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Error Downloading ...")
                    builder.setOngoing(false)
                    notify(2, builder.build())
                }
            }
        })
    }

    fun updateDb(youtubeurl: String, localUrl: String, thumbnailUrl: String) {
        val list = ArrayList<String>()
        list.add(youtubeurl)
        list.add(localUrl)
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("setDownloadComplete", list)
            MainActivity.updateDownloadStatus(list);
        }
        val youtubeUrl = "/watch?v=$youtubeurl"
        moojikDatabase = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READWRITE)
        val query = "update songs set isDownloaded=1 ,localUrl='$localUrl' ,thumbnailUrl='$thumbnailUrl' where youtubeUrl = '$youtubeUrl'"
        moojikDatabase.execSQL(query)
        moojikDatabase.close()
        downloadQueue.forEachIndexed { index, hashMap ->
            if (hashMap.containsKey(youtubeUrl)) {
                downloadQueue[index][youtubeUrl] = false
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("setDownloadComplete", downloadQueue)
                    MainActivity.updateDownloadStatus(list);
                }
            }
        }
    }

    private fun createNotificationChannel() {
        builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, "MoojikDownload")
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder.apply {
            setContentTitle("Initialising Download")
            setContentText("Please wait...")
            setSmallIcon(R.drawable.ic_download_icon)
            builder.setOngoing(true)
        }
        val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                    "MoojikDownload",
                    "MoojikDownload",
                    NotificationManager.IMPORTANCE_LOW
            )
            notificationChannel.enableLights(false)
            notificationChannel.enableVibration(false)
            notificationManager.createNotificationChannel(notificationChannel)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification = builder.setChannelId("MoojikDownload").build()
        } else {
            notification = builder.build()
            notificationManager.notify(2, notification)
        }
    }
}