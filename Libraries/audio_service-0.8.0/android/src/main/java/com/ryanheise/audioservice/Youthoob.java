package com.ryanheise.audioservice;

import android.os.Handler;
import android.os.Looper;

import com.github.kiulian.downloader.YoutubeDownloader;
import com.github.kiulian.downloader.YoutubeException;
import com.github.kiulian.downloader.model.YoutubeVideo;

import java.io.IOException;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodChannel;

class Youthoob implements Runnable {
    private String url;
    private YoutubeDownloader downloader = new YoutubeDownloader();
    private ArrayList<String> videoList  = new  ArrayList<>();
    private MethodChannel channel;
    Youthoob(String url,MethodChannel channel){
        this.channel = channel;
        this.url = url;
    }
    @Override
    public void run() {
        YoutubeVideo video = null;
        try {
            video = downloader.getVideo(url);
        } catch (YoutubeException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        assert video != null;
        this.videoList.add( video.audioFormats().get(0).url());
        this.videoList.add( video.details().thumbnails().get(3));
        this.videoList.add(url);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                channel.invokeMethod("setYoutubeLink",videoList);
            }
        });
    }
}
