import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:ezstudies/utils/preferences.dart';
import 'package:ezstudies/utils/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Update {
  static Directory? temp;
  static String port = "port";

  static Future<void> init() async {
    await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
    temp = await getTemporaryDirectory();
  }

  @pragma('vm:entry-point')
  static void callback(String id, int status, int progress) {
    SendPort send = IsolateNameServer.lookupPortByName(port)!;
    send.send([id, status, progress]);
  }

  static void checkUpdate(BuildContext context) async {
    if (Platform.isAndroid) {
      http
          .get(Uri.parse(
              "https://api.github.com/repos/Klbgr/EzStudies-Flutter/releases/latest"))
          .catchError((_) => http.Response("", 404))
          .then((response) {
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          Map json = jsonDecode(response.body);
          String tag1 = Preferences.packageInfo.version;
          String tag2 = json["tag_name"];
          String changelog = json["body"];
          String url = "";
          for (Map file in json["assets"]) {
            if (file["name"].endsWith(".apk")) {
              url = file["browser_download_url"];
              break;
            }
          }

          if ((tagIsGreater(tag2, tag1))) {
            showDialog(
                context: context,
                builder: (context) => AlertDialogTemplate(
                        title: AppLocalizations.of(context)!.update,
                        content: AppLocalizations.of(context)!
                            .update_desc(tag1, tag2, changelog),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child:
                                  Text(AppLocalizations.of(context)!.cancel)),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                launchUrl(
                                    Uri.parse(
                                        "https://github.com/Klbgr/EzStudies-Flutter/releases/latest"),
                                    mode: LaunchMode.externalApplication);
                              },
                              child: Text(AppLocalizations.of(context)!.open)),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                double downloadProgress = 0;
                                bool downloading = false;
                                String? downloadId;
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .downloading),
                                            content: StatefulBuilder(
                                                builder: (context, setState) {
                                              if (!downloading) {
                                                update(context, url,
                                                    (id, progress) {
                                                  setState(() =>
                                                      downloadProgress =
                                                          progress);
                                                  downloadId ??= id;
                                                });
                                                downloading = true;
                                              }
                                              return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    LinearProgressIndicator(
                                                      value: downloadProgress,
                                                    ),
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 10),
                                                        child: Text(
                                                            "${(downloadProgress * 100).round()}%"))
                                                  ]);
                                            }),
                                            scrollable: true,
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    try {
                                                      FlutterDownloader.cancel(
                                                          taskId: downloadId!);
                                                      FlutterDownloader.remove(
                                                          taskId: downloadId!);
                                                    } catch (_) {}
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .cancel))
                                            ]));
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.update)),
                        ]));
          }
        }
      });
    }
  }

  static Future<void> update(BuildContext context, String url,
      Function(String, double) onProgress) async {
    IsolateNameServer.removePortNameMapping(port);
    FlutterDownloader.registerCallback(callback);

    String? downloadId;
    String downloadFilename =
        "${AppLocalizations.of(context)!.app_name}_${DateTime.now()}.apk";

    try {
      FlutterDownloader.enqueue(
              url: url,
              savedDir: temp!.path,
              showNotification: false,
              openFileFromNotification: false,
              fileName: downloadFilename)
          .then((value) {
        downloadId = value;
      });
    } catch (_) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialogTemplate(
                title: AppLocalizations.of(context)!.error,
                content: AppLocalizations.of(context)!.error_internet,
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.ok))
                ],
              ));
    }

    ReceivePort receive = ReceivePort();
    IsolateNameServer.registerPortWithName(receive.sendPort, port);

    receive.listen((data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      if (id == downloadId) {
        if (DownloadTaskStatus.fromInt(status) == DownloadTaskStatus.complete) {
          try {
            FlutterDownloader.remove(taskId: id);
          } catch (_) {}
          Navigator.pop(context);
          OpenFilex.open("${temp?.path}/$downloadFilename",
              type: "application/vnd.android.package-archive");
        } else if (DownloadTaskStatus.fromInt(status) ==
            DownloadTaskStatus.running) {
          onProgress(id, progress / 100);
        }
      }
    });
  }

  static bool tagIsGreater(String tag1, String tag2) {
    try {
      List<int> t1 =
          tag1.split(".").map((element) => int.parse(element)).toList();
      List<int> t2 =
          tag2.split(".").map((element) => int.parse(element)).toList();
      if (t1[0] > t2[0]) {
        return true;
      } else if (t1[0] == t2[0]) {
        if (t1[1] > t2[1]) {
          return true;
        } else if (t1[1] == t2[1]) {
          if (t1[2] > t2[2]) {
            return true;
          } else if (t1[2] == t2[2]) {
            return false;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
