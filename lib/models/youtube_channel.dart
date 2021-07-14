import 'dart:convert';

class YoutubeChannel {
  String? kind;
  String? etag;
  PageInfo? pageInfo;
  List<ChannelItem>? items;

  YoutubeChannel({
    this.kind,
    this.etag,
    this.pageInfo,
    this.items,
  });

  factory YoutubeChannel.fromJson(String str) => YoutubeChannel.fromMap(jsonDecode(str));
  String toJson() => jsonEncode(toMap());

  YoutubeChannel.fromMap(Map<String, dynamic> json) {
    kind = json["kind"];
    etag = json["etag"];
    if (json["items"] != null) {
      items = <ChannelItem>[];
      json["items"].forEach((v) {
        items!.add(ChannelItem.fromJson(v));
      });
    }
    pageInfo = json['pageInfo'] != null ? PageInfo.fromJson(json['pageInfo']) : null;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['etag'] = etag;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (pageInfo != null) {
      data['pageInfo'] = pageInfo!.toJson();
    }
    return data;
  }
}

class ChannelItem {
  String? kind;
  String? etag;
  String? id;
  ChannelSnippet? snippet;
  ContentDetails? contentDetails;
  Statistics? statistics;

  ChannelItem({
    this.kind,
    this.etag,
    this.id,
    this.snippet,
    this.contentDetails,
    this.statistics,
  });

  ChannelItem.fromJson(Map<String, dynamic> json) {
    kind = json["kind"];
    etag = json["etag"];
    id = json["id"];
    snippet = json['snippet'] != null ? ChannelSnippet.fromJson(json['snippet']) : null;
    contentDetails = json["contentDetails"] != null ? ContentDetails.fromJson(json["contentDetails"]) : null;
    statistics = json["statistics"] != null ? Statistics.fromJson(json["statistics"]) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["kind"] = kind;
    data["etag"] = etag;
    data["id"] = id;
    if (snippet != null) {
      data["snippet"] = snippet!.toJson();
    }
    if (contentDetails != null) {
      data["contentDetails"] = contentDetails!.toJson();
    }
    if (statistics != null) {
      data["statistics"] = statistics!.toJson();
    }
    return data;
  }
}

class ContentDetails {
  RelatedPlaylists? relatedPlaylists;

  ContentDetails({
    this.relatedPlaylists,
  });

  ContentDetails.fromJson(Map<String, dynamic> json) {
    relatedPlaylists = RelatedPlaylists.fromJson(json["relatedPlaylists"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["relatedPlaylists"] = relatedPlaylists!.toJson();
    return data;
  }
}

class RelatedPlaylists {
  String? likes;
  String? favorites;
  String? uploads;
  String? watchHistory;
  String? watchLater;

  RelatedPlaylists({
    this.likes,
    this.favorites,
    this.uploads,
    this.watchHistory,
    this.watchLater,
  });

  RelatedPlaylists.fromJson(Map<String, dynamic> json) {
    likes = json["likes"];
    favorites = json["favorites"];
    uploads = json["uploads"];
    watchHistory = json["watchHistory"];
    watchLater = json["watchLater"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["likes"] = likes;
    data["favorites"] = favorites;
    data["uploads"] = uploads;
    data["watchHistory"] = watchHistory;
    data["watchLater"] = watchLater;
    return data;
  }
}

class ChannelSnippet {
  String? title;
  String? description;
  DateTime? publishedAt;
  ChannelThumbnails? thumbnails;
  Localized? localized;
  String? country;

  ChannelSnippet({
    this.title,
    this.description,
    this.publishedAt,
    this.thumbnails,
    this.localized,
    this.country,
  });

  ChannelSnippet.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    description = json["description"];
    publishedAt = DateTime.parse(json["publishedAt"]);
    thumbnails = ChannelThumbnails.fromJson(json["thumbnails"]);
    localized = Localized.fromJson(json["localized"]);
    country = json["country"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["description"] = description;
    data["publishedAt"] = publishedAt!.toIso8601String();
    data["thumbnails"] = thumbnails!.toJson();
    data["localized"] = localized!.toJson();
    data["country"] = country;
    return data;
  }
}

class Localized {
  String? title;
  String? description;

  Localized({
    this.title,
    this.description,
  });

  Localized.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    description = json["description"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["description"] = description;
    return data;
  }
}

class ChannelThumbnails {
  Default? thumbnailsDefault;
  Default? medium;
  Default? high;

  ChannelThumbnails({
    this.thumbnailsDefault,
    this.medium,
    this.high,
  });

  factory ChannelThumbnails.fromJson(Map<String, dynamic> json) => ChannelThumbnails(
        thumbnailsDefault: Default.fromJson(json["default"]),
        medium: Default.fromJson(json["medium"] ?? json["default"]),
        high: Default.fromJson(json["high"] ?? json["medium"] ?? json["default"]),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["default"] = thumbnailsDefault!.toJson();
    data["medium"] = medium!.toJson();
    data["high"] = high!.toJson();
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

  factory Default.fromJson(Map<String, dynamic> json) => Default(
        url: json["url"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "width": width,
        "height": height,
      };
}

class Statistics {
  String? viewCount;
  String? commentCount;
  String? subscriberCount;
  bool? hiddenSubscriberCount;
  String? videoCount;

  Statistics({
    this.viewCount,
    this.commentCount,
    this.subscriberCount,
    this.hiddenSubscriberCount,
    this.videoCount,
  });

  Statistics.fromJson(Map<String, dynamic> json) {
    viewCount = json["viewCount"];
    commentCount = json["commentCount"];
    subscriberCount = json["subscriberCount"];
    hiddenSubscriberCount = json["hiddenSubscriberCount"];
    videoCount = json["videoCount"];
  }

  Map<String, dynamic> toJson() => {
        "viewCount": viewCount,
        "commentCount": commentCount,
        "subscriberCount": subscriberCount,
        "hiddenSubscriberCount": hiddenSubscriberCount,
        "videoCount": videoCount,
      };
}

class PageInfo {
  int? resultsPerPage;

  PageInfo({
    this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        resultsPerPage: json["resultsPerPage"],
      );

  Map<String, dynamic> toJson() => {
        "resultsPerPage": resultsPerPage,
      };
}
