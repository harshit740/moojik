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
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.util.PathUtils
import java.io.File
import java.io.IOException
import kotlin.concurrent.thread


class DownloadService : JobIntentService() {
    companion object {
        lateinit var channel: MethodChannel
        var downloadQueue = HashMap<String, Boolean>()
        val currentQueueSize
            get() = downloadQueue.size;
        var JobId = 1001
        fun enQueueDownload(context: Context, intent: Intent) {
            val youtubeUrl = intent.getStringExtra("youtubeUrl")
            if (downloadQueue.isNotEmpty()) {
                if (downloadQueue.containsKey(youtubeUrl)) return
            }
            downloadQueue[youtubeUrl] = true
            enqueueWork(context, DownloadService::class.java, JobId, intent)
        }
    }

    private lateinit var outDir: File
    private lateinit var builder: Notification.Builder
    private lateinit var notification: Notification

    override fun onCreate() {
        try {
            createNotificationChannel()
            if (!outDir.exists()) {
                val mkdirs = outDir.mkdirs()
                if (!mkdirs) throw IOException("Could not create output directory: ${outDir.absolutePath}")
            }
        } catch (e: Exception) {
        }
        super.onCreate()
    }

    override fun onDestroy() {
        super.onDestroy()
    }
    override fun onHandleWork(intent: Intent) {
        outDir = File(PathUtils.getDataDirectory(this), "/Moojik/")
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setSubText("$currentQueueSize Files Downloading")
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
                Handler(Looper.getMainLooper()).post {
                    MainActivity.updateDownloadProgress(youtubeUrl)
                }
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Downloading...")
                            .setProgress(100, progress, false)
                    if (progress < 99) {
                        builder.setOngoing(false)
                    }
                    notify(2, builder.build())
                }
            }

            override fun onFinished(file: File) {
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Download Complete")
                    builder.setProgress(0, 0, false)
                    builder.setOngoing(false)
                    builder.setAutoCancel(true)
                    notify(2, builder.build())
                }
                thread(start = true,isDaemon = true) {
                    updateDb(youtubeUrl, file.absolutePath, video.details().thumbnails().run { this[this.size - 1] }.toString())
                }
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
       val file = File(PathUtils.getDataDirectory(this), "MoojkFlux.db")
       var moojikDatabase = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READWRITE)
        val list = ArrayList<String>()
        list.add(youtubeurl)
        list.add(localUrl)
        Handler(Looper.getMainLooper()).post {
            MainActivity.updateDownloadComplete(list)
        }
        downloadQueue[youtubeurl] = false
        val youtubeUrl = "/watch?v=$youtubeurl"
        val query = "update songs set isDownloaded=1 ,localUrl='$localUrl' ,thumbnailUrl='$thumbnailUrl' where youtubeUrl = '$youtubeUrl'"
        moojikDatabase.execSQL(query);
        moojikDatabase.close()
        moojikDatabase = null;
        Log.d("Download Service ","kam ho gaya ");
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentText("Download Complete")
            builder.setProgress(0, 0, false)
            builder.setOngoing(false)
            builder.setAutoCancel(true)
            notify(2, builder.build())
        }
        return
    }
    override fun onStopCurrentWork(): Boolean {
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentText("Download Complete")
            builder.setProgress(0, 0, false)
            builder.setOngoing(false)
            builder.setAutoCancel(true)
            notify(2, builder.build())
        }
        return super.onStopCurrentWork()
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