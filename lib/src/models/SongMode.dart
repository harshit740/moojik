class Song {
  final String title;
  final String desc;
  final String youtubeUrl;
   String localUrl;
   bool isDownloaded;
  String thumbnailUrl;
  bool isFteched = false;
  String lastYoutubeLenk = '';
  String lastFetchedOn = "";
  bool isFetching = false;

  Song(this.title, this.desc, this.youtubeUrl, this.localUrl, this.isDownloaded, this.thumbnailUrl);

  
}

