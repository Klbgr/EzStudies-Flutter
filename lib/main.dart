import 'dart:async';
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:ezstudies/agenda/agenda.dart';
import 'package:ezstudies/agenda/agenda_view_model.dart';
import 'package:ezstudies/homeworks/homeworks.dart';
import 'package:ezstudies/search/search.dart';
import 'package:ezstudies/settings/Settings.dart';
import 'package:ezstudies/utils/notifications.dart';
import 'package:ezstudies/utils/preferences.dart';
import 'package:ezstudies/utils/style.dart';
import 'package:ezstudies/welcome/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_strategy/url_strategy.dart';

import 'config/env.dart';
import 'firebase_options.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }
    if (!Platform.isIOS) {
      SystemTheme.accentColor;
    }
    await Preferences.load();
    await Style.load();
    await Notifications.initNotifications();
    setPathUrlStrategy();
    runApp(const EzStudies());
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

class EzStudies extends StatefulWidget {
  const EzStudies({Key? key}) : super(key: key);

  @override
  State<EzStudies> createState() => _EzStudiesState();
}

class _EzStudiesState extends State<EzStudies> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            timePickerTheme: TimePickerThemeData(
                backgroundColor: Style.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                helpTextStyle: TextStyle(color: Style.text),
                hourMinuteColor: Style.secondary,
                dialBackgroundColor: Style.secondary,
                dialTextColor: Style.text,
                hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Style.primary
                        : Style.text),
                entryModeIconColor: Style.text),
            textTheme:
                GoogleFonts.openSansTextTheme(Theme.of(context).textTheme.apply(
                      bodyColor: Style.text,
                      displayColor: Style.text,
                    )),
            textSelectionTheme:
                TextSelectionThemeData(selectionColor: Style.primary),
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Style.primary,
                secondary: Style.primary,
                onSurface: Style.text),
            dialogTheme: DialogTheme(
                backgroundColor: Style.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            unselectedWidgetColor: Style.text,
            toggleableActiveColor: Style.primary,
            splashColor: Style.ripple,
            highlightColor: Style.ripple),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        title: "EzStudies",
        home: ((Preferences.sharedPreferences.getString(Preferences.name) ?? "")
                    .isNotEmpty &&
                (Preferences.sharedPreferences
                            .getString(Preferences.password) ??
                        "")
                    .isNotEmpty)
            ? Main(
                reloadTheme: () => setState(() {}),
              )
            : const Welcome());
  }
}

class Main extends StatefulWidget {
  const Main({this.reloadTheme, Key? key}) : super(key: key);
  final Function? reloadTheme;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int selectedIndex = 0;
  bool showBanner = true;
  AgendaViewModel agendaViewModel = AgendaViewModel();

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[
      Agenda(agenda: true, agendaViewModel: agendaViewModel),
      const Search(),
      if (!kIsWeb) const Homeworks(),
      Settings(
          reloadTheme: () => setState(() {
                if (widget.reloadTheme != null) {
                  widget.reloadTheme!();
                }
              })),
    ];
    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: getIcon(0),
        label: AppLocalizations.of(context)!.agenda,
      ),
      BottomNavigationBarItem(
        icon: getIcon(1),
        label: AppLocalizations.of(context)!.search,
      ),
      if (!kIsWeb)
        BottomNavigationBarItem(
          icon: getIcon(2),
          label: AppLocalizations.of(context)!.homeworks,
        ),
      BottomNavigationBarItem(
        icon: getIcon(kIsWeb ? 2 : 3),
        label: AppLocalizations.of(context)!.settings,
      ),
    ];

    Widget bottomNavigationBar = BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Style.secondary,
        items: items,
        currentIndex: selectedIndex,
        selectedItemColor: Style.text,
        unselectedItemColor: Style.text,
        iconSize: 24,
        unselectedFontSize: 16,
        selectedFontSize: 16,
        onTap: (value) => setState(() => selectedIndex = value));
    if (kIsWeb && showBanner) {
      bottomNavigationBar = Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                color: Style.primary,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.banner,
                          style: TextStyle(color: Style.text)),
                      IconButton(
                          onPressed: () => setState(() => showBanner = false),
                          icon: Icon(Icons.close, color: Style.text))
                    ])),
            onTap: () => launchUrl(Uri.parse("${Secret.server_url}install"),
                mode: LaunchMode.externalApplication)),
        bottomNavigationBar
      ]);
    }

    return Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (
            child,
            animation,
            secondaryAnimation,
          ) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              fillColor: Style.background,
              child: child,
            );
          },
          child: widgets[selectedIndex],
        ),
        bottomNavigationBar: bottomNavigationBar);
  }

  @override
  void initState() {
    super.initState();
    checkUpdate();
  }

  Widget getIcon(int index) {
    const List<IconData> icons = <IconData>[
      Icons.view_agenda_outlined,
      Icons.search_outlined,
      if (!kIsWeb) Icons.library_books_outlined,
      Icons.settings_outlined
    ];

    const List<IconData> iconsSelected = <IconData>[
      Icons.view_agenda,
      Icons.search,
      if (!kIsWeb) Icons.library_books,
      Icons.settings
    ];

    return Container(
        decoration: BoxDecoration(
            color:
                (index == selectedIndex) ? Style.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 5),
        margin: const EdgeInsets.only(bottom: 5),
        child: Icon(
            (index == selectedIndex) ? iconsSelected[index] : icons[index],
            color: Style.text));
  }

  Future<void> checkUpdate() async {
    if (!kIsWeb) {
      http.Response response = await http
          .get(Uri.parse(
              "https://api.github.com/repos/Klbgr/EzStudies-Flutter/releases/latest"))
          .catchError((_) => http.Response("", 404));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        String tag = jsonDecode(response.body)["tag_name"];
        if ((tagIsGreater(tag, Preferences.packageInfo.version))) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.update),
                      content: Text(AppLocalizations.of(context)!.update_desc),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context)!.cancel)),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              launchUrl(
                                  Uri.parse("${Secret.server_url}install"),
                                  mode: LaunchMode.externalApplication);
                            },
                            child: Text(AppLocalizations.of(context)!.update)),
                      ]));
        }
      }
    }
  }

  bool tagIsGreater(String tag1, String tag2) {
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
