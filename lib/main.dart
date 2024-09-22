import 'dart:async';

import 'package:animations/animations.dart';
import 'package:ezstudies/agenda/agenda.dart';
import 'package:ezstudies/agenda/agenda_view_model.dart';
import 'package:ezstudies/homeworks/homeworks.dart';
import 'package:ezstudies/search/search.dart';
import 'package:ezstudies/settings/Settings.dart';
import 'package:ezstudies/utils/notifications.dart';
import 'package:ezstudies/utils/preferences.dart';
import 'package:ezstudies/utils/style.dart';
import 'package:ezstudies/utils/update.dart';
import 'package:ezstudies/welcome/welcome.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      await Update.init();
    }
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
    await FirebaseAnalytics.instance.logAppOpen();
    if (!Platform.isIOS) {
      SystemTheme.accentColor;
    }
    await Preferences.load();
    await Style.load();
    await Notifications.initNotifications();
    setPathUrlStrategy();
    runApp(const EzStudies());
  }, (error, stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

class EzStudies extends StatefulWidget {
  const EzStudies({super.key});

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('fr', ''),
  ];

  @override
  State<EzStudies> createState() => _EzStudiesState();
}

class _EzStudiesState extends State<EzStudies> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light, seedColor: Style.primary),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark, seedColor: Style.primary),
          useMaterial3: true,
        ),
        themeMode: (Style.theme == 0) ? ThemeMode.light : ThemeMode.dark,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: EzStudies.supportedLocales,
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
  const Main({this.reloadTheme, super.key});

  final Function? reloadTheme;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int selectedIndex = 0;
  bool showBanner = true;
  bool showBannerMessage = true;
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
    List<Widget> items = [
      NavigationDestination(
        icon: const Icon(
          Icons.view_agenda_outlined,
        ),
        label: AppLocalizations.of(context)!.agenda,
        tooltip: AppLocalizations.of(context)!.agenda,
        selectedIcon: const Icon(Icons.view_agenda),
      ),
      NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          label: AppLocalizations.of(context)!.search,
          tooltip: AppLocalizations.of(context)!.search,
          selectedIcon: const Icon(
            Icons.search_outlined,
          )),
      if (!kIsWeb)
        NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            label: AppLocalizations.of(context)!.homeworks,
            tooltip: AppLocalizations.of(context)!.homeworks,
            selectedIcon: const Icon(
              Icons.library_books,
            )),
      NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          label: AppLocalizations.of(context)!.settings,
          tooltip: AppLocalizations.of(context)!.settings,
          selectedIcon: const Icon(Icons.settings)),
    ];

    Widget bottomNavigationBar =
        Column(mainAxisSize: MainAxisSize.min, children: [
      if (showBannerMessage)
        GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                color: Theme.of(context).colorScheme.error,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.banner_message,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onError),
                      ),
                      IconButton(
                          onPressed: () =>
                              setState(() => showBannerMessage = false),
                          icon: Icon(Icons.close,
                              color: Theme.of(context).colorScheme.onError))
                    ])),
            onTap: () => launchUrl(
                Uri.parse(
                    "https://github.com/Klbgr/EzStudies-Flutter?tab=readme-ov-file#deprecated"),
                mode: LaunchMode.externalApplication)),
      if (kIsWeb && showBanner)
        GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                color: Theme.of(context).colorScheme.primary,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.banner,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      IconButton(
                          onPressed: () => setState(() => showBanner = false),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ))
                    ])),
            onTap: () => launchUrl(Uri.parse("${Secret.server_url}install"),
                mode: LaunchMode.externalApplication)),
      NavigationBar(
          destinations: items,
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
    ]);

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
    Update.checkUpdate(context);
  }
}
