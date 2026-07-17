import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTML版 DEFAULTS と同じ初期値。
class Defaults {
  static const tab = 'post';
  static const date = '2026-06-13';
  static const title = '#TRCゆる部 ナイトレース';
  static const time = '21:45';
  static const body = '今回は新しいレイアウトでの初レース♪\nどんなレースになるか楽しみ';
  static const minutes = '15';
  static const url = 'https://youtube.com/live/c8zrG_XybXk';
  static const tags = '#ミニ四駆 #レース配信 #かえで配信中';
  static const qr = true;
  static const rr = true;
  static const editMode = 'full';
  static const qualityMode = true;
}

/// 全入力状態。変更のたびにデバウンス付きで shared_preferences へ保存する。
class AppState extends ChangeNotifier {
  AppState({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  static const storeKey = 'kaede-toolbox:v1';

  final SharedPreferencesAsync _prefs;
  Timer? _saveTimer;

  // ---- 共通 ----
  String tab = Defaults.tab; // 'post' | 'thumb'
  String date = Defaults.date; // yyyy-MM-dd（告知⇄サムネ共有）

  // ---- 告知 ----
  String title = Defaults.title;
  String time = Defaults.time; // HH:mm
  String body = Defaults.body;
  String minutes = Defaults.minutes;
  String url = Defaults.url;
  String tags = Defaults.tags;
  bool qr = Defaults.qr;
  bool rr = Defaults.rr;

  // ---- サムネ ----
  String editMode = Defaults.editMode; // 'full' | 'badgeOnly'
  bool qualityMode = Defaults.qualityMode;
  String mainTitle = '';
  String subTitle = '';
  String eventSub = '';
  List<String> contents = [''];
  String charText = '';
  String badgeLine1 = '';
  String badgeLine2 = '';
  String badgeDate = '';
  String extraNote = '';
  String output = '';

  Map<String, dynamic> toJson() => {
        'tab': tab,
        'date': date,
        'title': title,
        'time': time,
        'body': body,
        'minutes': minutes,
        'url': url,
        'tags': tags,
        'qr': qr,
        'rr': rr,
        'editMode': editMode,
        'qualityMode': qualityMode,
        'mainTitle': mainTitle,
        'subTitle': subTitle,
        'eventSub': eventSub,
        'contents': contents,
        'charText': charText,
        'badgeLine1': badgeLine1,
        'badgeLine2': badgeLine2,
        'badgeDate': badgeDate,
        'extraNote': extraNote,
        'output': output,
      };

  void _applyJson(Map<String, dynamic> j) {
    String s(String key, String fallback) =>
        j[key] is String ? j[key] as String : fallback;
    bool b(String key, bool fallback) =>
        j[key] is bool ? j[key] as bool : fallback;

    tab = s('tab', Defaults.tab);
    date = s('date', Defaults.date);
    title = s('title', Defaults.title);
    time = s('time', Defaults.time);
    body = s('body', Defaults.body);
    minutes = s('minutes', Defaults.minutes);
    url = s('url', Defaults.url);
    tags = s('tags', Defaults.tags);
    qr = b('qr', Defaults.qr);
    rr = b('rr', Defaults.rr);
    editMode = s('editMode', Defaults.editMode);
    qualityMode = b('qualityMode', Defaults.qualityMode);
    mainTitle = s('mainTitle', '');
    subTitle = s('subTitle', '');
    eventSub = s('eventSub', '');
    charText = s('charText', '');
    badgeLine1 = s('badgeLine1', '');
    badgeLine2 = s('badgeLine2', '');
    badgeDate = s('badgeDate', '');
    extraNote = s('extraNote', '');
    output = s('output', '');
    final c = j['contents'];
    contents = c is List
        ? c.map((e) => e is String ? e : '').toList()
        : [''];
    if (contents.isEmpty) contents = [''];
  }

  /// 保存データがあれば復元する。戻り値は「前回の内容を読み込んだか」。
  Future<bool> load() async {
    try {
      final raw = await _prefs.getString(storeKey);
      if (raw == null || raw.isEmpty) return false;
      final j = jsonDecode(raw);
      if (j is! Map<String, dynamic>) return false;
      _applyJson(j);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 変更を通知しつつ、350ms デバウンスで保存する。
  void update(void Function() mutate) {
    mutate();
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 350), () {
      _prefs.setString(storeKey, jsonEncode(toJson())).catchError((_) {});
    });
  }

  /// 告知タブを初期値に戻す（HTML版 resetPostBtn と同じ範囲）。
  void resetPost() {
    update(() {
      title = Defaults.title;
      body = Defaults.body;
      minutes = Defaults.minutes;
      url = Defaults.url;
      tags = Defaults.tags;
      qr = Defaults.qr;
      rr = Defaults.rr;
      date = Defaults.date;
      time = Defaults.time;
    });
  }

  /// サムネタブの入力をクリアする（日付は共有なので保持）。
  void resetThumb() {
    update(() {
      mainTitle = '';
      subTitle = '';
      eventSub = '';
      charText = '';
      badgeLine1 = '';
      badgeLine2 = '';
      badgeDate = '';
      extraNote = '';
      qualityMode = true;
      contents = [''];
      output = '';
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
