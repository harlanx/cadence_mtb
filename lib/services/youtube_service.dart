import 'dart:convert';
import 'dart:io';
import 'package:cadence_mtb/models/youtube_channel.dart';
import 'package:cadence_mtb/models/youtube_videos.dart';
import 'package:cadence_mtb/utilities/keys.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class YoutubeService {
  static const _baseURL = 'www.googleapis.com';
  static const Map<String, String> headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  static Future<YoutubeVideos> getVideosList({
    required String playListId,
    //String pageToken,
  }) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playListId,
      'maxResults': '26', //Max is 50 as per Youtube API Documentation. 26 is our total count of videos.
      //'pageToken': pageToken, <= USEFUL FOR PAGINATION
      'key': Constants.googleApiKey,
    };
    Uri uri = Uri.https(_baseURL, '/youtube/v3/playlistItems', parameters);
    Response response = await http.get(uri, headers: headers);
    //print(response.body);
    if (response.statusCode == 200) {
      YoutubeVideos videosList = YoutubeVideos.fromJson(response.body);
      //print('Service Working');
      //print(response.body);
      return videosList;
    } else {
      //print('Services Error');
      throw jsonDecode(response.body)['error']['message'];
    }
  }

  static Future<YoutubeChannel> getChannelInfo({required String channelID}) async {
    Map<String, String> parameters = {
      'part': 'snippet, statistics',
      'id': channelID,
      'key': Constants.googleApiKey,
    };

    Uri uri = Uri.https(_baseURL, '/youtube/v3/channels', parameters);
    Response response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      //print('Service Working');
      //print(response.body);
      YoutubeChannel channelInfo = YoutubeChannel.fromJson(response.body);
      return channelInfo;
    } else {
      //print('Services Error');
      throw jsonDecode(response.body)['error']['message'];
    }
  }
}
