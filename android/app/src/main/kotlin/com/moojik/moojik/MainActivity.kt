package com.moojik.moojik

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.github.kiulian.downloader.YoutubeDownloader
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlin.concurrent.thread


class MainActivity : FlutterActivity() {
    companion object {
        const val CHANNEL = "com.moojikflux/music"
    }
    private lateinit var   channel:MethodChannel;
    /** This is a temporary workaround to avoid a memory leak in the Flutter framework  */
    override fun provideFlutterEngine(context: Context): FlutterEngine? { // Instantiate a FlutterEngine.
        val flutterEngine = FlutterEngine(context.applicationContext)
        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        )
        return flutterEngine
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getYoutubeLenk") {
                    getYoutube(call.arguments as String)
                    result.success("Called Get youtube");
            } else {
                result.notImplemented()
            }
            // Note: this method is invoked on the main thread.
            // TODO
        }
        channel.invokeMethod("message", "Hello from native host")
    }


    private fun getYoutube(url:String) {
        thread {
            val videoDetails = ArrayList<String>();
            val video = YoutubeDownloader().getVideo(url);
            videoDetails.add(0, videoDetails.add(video.audioFormats().run { this[this.size - 1] }.url()).toString())
            videoDetails.add(videoDetails.add(video.details().thumbnails().run { this[this.size - 1] }).toString())
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("setYoutubeLenk", videoDetails);
            }
        }
         
    }

}

/*
if (call.method == "startYoutubeDownload") {
                print("Native Method");
                Log.d("1","Loggin YOuthoo");
                print(call.arguments);
                thread {
                        val video = YoutubeDownloader().getVideo("A0T6LwpJGxw")
                        val videoWithAudioFormats = video.videoWithAudioFormats()
                        print(videoWithAudioFormats[0].url());
                       //activity.runOnUiThread
                        //result.success(videoWithAudioFormats[0].url());
                }
* **/