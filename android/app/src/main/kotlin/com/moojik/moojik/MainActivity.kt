package com.moojik.moojik

import android.content.Intent
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.github.kiulian.downloader.YoutubeDownloader
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread


class MainActivity : FlutterActivity() {
    companion object {
        const val CHANNEL = "com.moojikflux/music"
        lateinit var flutterEngineInstance: FlutterEngine;
        lateinit var channel: MethodChannel
        fun updateDownloadComplete(list:ArrayList<String>){
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("setDownloadComplete", list)
            }
        }
        fun updateDownloadProgress(youtubeUrl:String){
                channel.invokeMethod("setDownloadStatus", youtubeUrl)
        }
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        flutterEngineInstance = flutterEngine
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getYoutubeLenk" -> {
                    getYoutube(call.arguments as String)
                    result.success("Called Get youtube")
                }
                "addToDownloadQueue" -> {
                    result.success(true);
                    val downloadIntent:Intent = Intent(applicationContext, DownloadService::class.java)
                            .putExtra("youtubeUrl", call.arguments as String)
                    DownloadService.enQueueDownload(context, downloadIntent)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        channel.invokeMethod("message", "Hello from native host")
    }

    private fun getYoutube(url: String) {
        thread {
            val videoDetails = ArrayList<String>()
            val video = YoutubeDownloader().getVideo(url)
            videoDetails.add(0, videoDetails.add(video.audioFormats().run { this[this.size - 1] }.url()).toString())
            videoDetails.add(videoDetails.add(video.details().thumbnails().run { this[this.size - 1] }).toString())
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("setYoutubeLenk", videoDetails)
            }
        }
    }
}