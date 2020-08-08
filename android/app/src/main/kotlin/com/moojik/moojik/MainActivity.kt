package com.moojik.moojik

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.github.kiulian.downloader.YoutubeDownloader
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.schabi.newpipe.extractor.InfoItem
import org.schabi.newpipe.extractor.NewPipe
import kotlin.concurrent.thread
import org.schabi.newpipe.extractor.ServiceList.YouTube
import org.schabi.newpipe.extractor.downloader.Downloader
import org.schabi.newpipe.extractor.playlist.PlaylistInfoItem
import org.schabi.newpipe.extractor.search.SearchExtractor
import org.schabi.newpipe.extractor.services.youtube.linkHandler.YoutubeSearchQueryHandlerFactory
import org.schabi.newpipe.extractor.stream.StreamExtractor
import org.schabi.newpipe.extractor.stream.StreamInfoItem
import java.util.Collections.singletonList

class MainActivity : FlutterActivity() {
    companion object {
        const val CHANNEL = "com.moojikflux/music"
        lateinit var flutterEngineInstance: FlutterEngine
        lateinit var channel: MethodChannel
        fun updateDownloadComplete(list: ArrayList<String>) {
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("setDownloadComplete", list)
            }
        }

        fun updateDownloadProgress(youtubeUrl: String) {
            channel.invokeMethod("setDownloadStatus", youtubeUrl)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineInstance = flutterEngine
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getYoutubeLenk" -> {
                    getYoutube(call.arguments as String)
                    result.success("Called Get youtube")
                }
                "addToDownloadQueue" -> {
                    result.success(true)
                    val downloadIntent: Intent = Intent(activity.applicationContext, DownloadService::class.java)
                            .putExtra("youtubeUrl", call.arguments as String)
                    DownloadService.enQueueDownload(context, downloadIntent)
                }
                "getYoutubeSearch" -> {
                    thread {
                        getyotubeSearch(call.arguments as String)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        channel.invokeMethod("message", "Hello from native host")
    }

    private fun getYotubePlaylist(qury: String) {
        val songName = ArrayList<String>()
        val songUrl = ArrayList<String>()
        val songSearch = ArrayList<ArrayList<String>>()
        val songThumbnail = ArrayList<String>()
        NewPipe.init(CustomDownloader.instance)
        val extractor = YouTube.getSearchExtractor(qury, singletonList(
                YoutubeSearchQueryHandlerFactory.ALL), "")
        extractor.fetchPage()
        for (song in extractor.initialPage.items) {
            songName.add(song.name)
            songUrl.add(song.url.split(".com")[1])
            songThumbnail.add(song.thumbnailUrl)
            Log.d("Songs", song.name + " " + song.url.split(".com")[1])
        }
        songSearch.add(songName)
        songSearch.add(songUrl)
        songSearch.add(songThumbnail)
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("setYoutubeSearch", songSearch)
        }

    }

    private fun getyotubeSearch(qury: String) {
        val songName = ArrayList<String>()
        val songUrl = ArrayList<String>()
        val songSearch = ArrayList<ArrayList<String>>()
        val songThumbnail = ArrayList<String>()
        val songYOutubeSteam = ArrayList<String>()
        NewPipe.init(CustomDownloader.instance)
        val extractor = YouTube.getSearchExtractor(qury, singletonList(
                YoutubeSearchQueryHandlerFactory.ALL), "")
        extractor.fetchPage()
        for (song in extractor.initialPage.items) {
            if (song.url.contains("https://www.youtube.com/channel/")) {
                print("Opps CHane;");
            } else {
                songName.add(song.name)
                songUrl.add(song.url.split(".com")[1])
                songThumbnail.add(song.thumbnailUrl)
            }
        }
        songSearch.add(songName)
        songSearch.add(songUrl)
        songSearch.add(songThumbnail)
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("setYoutubeSearch", songSearch)
        }
    }

    private fun getYoutube(url: String) {
        thread {
            val videoDetails = ArrayList<String>()
            val video = YoutubeDownloader().getVideo(url)
            videoDetails.add(0, videoDetails.add(video.audioFormats().run { this[this.size - 1] }.url()).toString())
            videoDetails.add(videoDetails.add(video.details().thumbnails().run { this[this.size - 1] }).toString())
            print(YouTube.getLinkTypeByUrl(url))
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod("setYoutubeLenk", videoDetails)
            }
        }
    }
}

class Song {
    var name = " n"
    var url = ""

}