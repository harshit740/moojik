package com.moojik.moojik

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import androidx.core.app.JobIntentService
import androidx.core.app.NotificationManagerCompat
import com.github.kiulian.downloader.OnYoutubeDownloadListener
import com.github.kiulian.downloader.YoutubeDownloader
import io.flutter.Log
import io.flutter.util.PathUtils
import java.io.File
import java.io.IOException


class DownloadService : JobIntentService() {
    companion object {
        var JobId = 1001
        fun enQueueDownload(context: Context, intent: Intent) {
            val youtubeUrl = intent.getStringExtra("youtubeUrl")
            Log.d("Enqueue Download OnHandelWork", "youtubeUrl $youtubeUrl")
            enqueueWork(context, DownloadService::class.java, JobId, intent)
        }
    }

    lateinit var mydatabase: SQLiteDatabase
    lateinit var file: File
    lateinit var outDir: File
    private lateinit var builder: Notification.Builder
    private lateinit var notification: Notification

    override fun onCreate() {
        try {
            outDir = File(PathUtils.getDataDirectory(this), "/Moojik/")
            file = File(PathUtils.getDataDirectory(this) ,"MoojkFlux.db")
            mydatabase = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READWRITE)
            Log.d("DownloadService", "DownloadService Started")
            //Log.d("DownloadService","DownloadService Started ${songs.getString(0)}");
            createNotificationChannel()
            if (!outDir.exists()) {
                val mkdirs = outDir.mkdirs()
                if (!mkdirs) throw IOException("Could not create output directory: ${outDir.absolutePath}")
            }
        } catch (e: Exception) {
            mydatabase.close()
        }
        super.onCreate()
    }

    override fun onHandleWork(intent: Intent) {
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentTitle("Starting")
            builder.setOngoing(true)
            notify(2, builder.build())
        }
        Log.d("OnHandelWork", "Intent ${intent.data}")
        val youtubeUrl = intent.getStringExtra("youtubeUrl")
        Log.d("OnHandelWork", "youtubeUrl $youtubeUrl")
        val video = YoutubeDownloader().getVideo(youtubeUrl)
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentTitle(video.details().title())
            builder.setOngoing(true)
            notify(2, builder.build())
        }
        suspend { }
        video.downloadAsync(video.audioFormats().run { this[this.size - 1] }, outDir, youtubeUrl, object : OnYoutubeDownloadListener {
            override fun onDownloading(progress: Int) {
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Downloading...")
                            .setProgress(100, progress, false)
                    builder.setOngoing(true)
                    notify(2, builder.build())
                }
            }

            override fun onFinished(file: File) {
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Saving...")
                            .setProgress(100, 1000, true)
                    builder.setOngoing(true)
                    notify(2, builder.build())
                }
                updateDb(youtubeUrl, file.absolutePath,video.details().thumbnails().run { this[this.size - 1] }.toString())
            }

            override fun onError(throwable: Throwable?) {
                NotificationManagerCompat.from(applicationContext).apply {
                    builder.setContentText("Error Downloading ...")
                    builder.setOngoing(false)
                    notify(2, builder.build())
                }
                TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
            }

        })

    }

    fun updateDb(youtubeurl: String, localUrl: String,thumbnailUrl:String) {
        NotificationManagerCompat.from(applicationContext).apply {
            builder.setContentText("DownloadComplete")
            builder.setAutoCancel(true)
            builder.setOngoing(false)
            notify(2, builder.build())
        }
        val youtubeUrl = "/watch?v=$youtubeurl"
        mydatabase = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READWRITE)
        val query = "update songs set isDownloaded=1 ,localUrl='$localUrl' ,thumbnailUrl='$thumbnailUrl' where youtubeUrl = '$youtubeUrl'"
        mydatabase.execSQL(query)
        mydatabase.close()
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