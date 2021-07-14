import 'dart:convert';

class YoutubeVideos {
  String? kind;
  String? etag;
  String? nextPageToken;
  List<VideoItem>? items;
  PageInfo? pageInfo;

  YoutubeVideos({
    this.kind,
    this.etag,
    this.nextPageToken,
    this.items,
    this.pageInfo,
  });

  factory YoutubeVideos.fromJson(String str) => YoutubeVideos.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  YoutubeVideos.fromMap(Map<String, dynamic> json) {
    kind = json['kind'];
    etag = json['etag'];
    nextPageToken = json['nextPageToken'];
    if (json['items'] != null) {
      items = <VideoItem>[];
      json['items'].forEach((v) {
        items!.add(VideoItem.fromJson(v));
      });
    }
    pageInfo = json['pageInfo'] != null ? PageInfo.fromJson(json['pageInfo']) : null;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['etag'] = etag;
    data['nextPageToken'] = nextPageToken;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (pageInfo != null) {
      data['pageInfo'] = pageInfo!.toJson();
    }
    return data;
  }
}

class VideoItem {
  String? kind;
  String? etag;
  String? id;
  VideoSnippet? snippet;

  VideoItem({
    this.kind,
    this.etag,
    this.id,
    required this.snippet,
  });

  VideoItem.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    etag = json['etag'];
    id = json['id'];
    snippet = json['snippet'] != null ? VideoSnippet.fromJson(json['snippet']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['etag'] = etag;
    data['id'] = id;
    data['snippet'] = snippet?.toJson();

    return data;
  }
}

class VideoSnippet {
  String? publishedAt;
  String? channelId;
  String title;
  String description;
  VideoThumbnails? thumbnails;
  String? channelTitle;
  String? playlistId;
  int? position;
  ResourceId? resourceId;
  String? videoOwnerChannelTitle;
  String videoOwnerChannelId;

  VideoSnippet({
    this.publishedAt,
    this.channelId,
    required this.title,
    required this.description,
    this.thumbnails,
    this.channelTitle,
    this.playlistId,
    this.position,
    required this.resourceId,
    this.videoOwnerChannelTitle,
    required this.videoOwnerChannelId,
  });

  VideoSnippet.fromJson(Map<String, dynamic> json) :
    publishedAt = json['publishedAt'],
    channelId = json['channelId'],
    title = json['title'],
    description = json['description'],
    thumbnails = json['thumbnails'] != null ? VideoThumbnails.fromJson(json['thumbnails']) : null,
    channelTitle = json['channelTitle'],
    playlistId = json['playlistId'],
    position = json['position'],
    resourceId = json['resourceId'] != null ? ResourceId.fromJson(json['resourceId']) : null,
    videoOwnerChannelTitle = json['videoOwnerChannelTitle'],
    videoOwnerChannelId = json['videoOwnerChannelId'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publishedAt'] = publishedAt;
    data['channelId'] = channelId;
    data['title'] = title;
    data['description'] = description;
    if (thumbnails != null) {
      data['thumbnails'] = thumbnails!.toJson();
    }
    data['channelTitle'] = channelTitle;
    data['playlistId'] = playlistId;
    data['position'] = position;
    data['resourceId'] = resourceId?.toJson();
    data['videoOwnerChannelTitle'] = this.videoOwnerChannelTitle;
    data['videoOwnerChannelId'] = this.videoOwnerChannelId;
    return data;
  }
}

class VideoThumbnails {
  Default? thumbnailsDefault;
  Default? medium;
  Default? high;
  Default? standard;
  Default? maxres;

  VideoThumbnails({
    this.thumbnailsDefault,
    this.medium,
    this.high,
    this.standard,
    this.maxres,
  });

  factory VideoThumbnails.fromJson(Map<String, dynamic> json) => VideoThumbnails(
      thumbnailsDefault: Default.fromJson(json['default']),
      medium: Default.fromJson(json['medium'] ?? json['default']),
      high: Default.fromJson(json['high'] ?? json['medium'] ?? json['default']),
      standard: Default.fromJson(json['standard'] ?? json['high'] ?? json['medium'] ?? json['default']),
      maxres: Default.fromJson(json['maxres'] ?? json['standard'] ?? json['high'] ?? json['medium'] ?? json['default']));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (thumbnailsDefault != null) {
      data['default'] = thumbnailsDefault!.toJson();
    }
    if (medium != null) {
      data['medium'] = medium!.toJson();
    }
    if (high != null) {
      data['high'] = high!.toJson();
    }
    if (standard != null) {
      data['standard'] = standard!.toJson();
    }
    if (maxres != null) {
      data['maxres'] = maxres!.toJson();
    }
    return data;
  }
}

class Default {
  String? url;
  int? width;
  int? height;

  Default({
    this.url,
    this.width,
    this.height,
  });

  Default.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['width'] = width;
    data['height'] = height;
    return data;
  }
}

class ResourceId {
  String? kind;
  String videoId;

  ResourceId({
    this.kind,
    required this.videoId,
  });

  ResourceId.fromJson(Map<String, dynamic> json) :
    kind = json['kind'],
    videoId = json['videoId'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['videoId'] = videoId;
    return data;
  }
}

class PageInfo {
  int? totalResults;
  int? resultsPerPage;

  PageInfo({
    this.totalResults,
    this.resultsPerPage,
  });

  PageInfo.fromJson(Map<String, dynamic> json) {
    totalResults = json['totalResults'];
    resultsPerPage = json['resultsPerPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalResults'] = totalResults;
    data['resultsPerPage'] = resultsPerPage;
    return data;
  }
}
