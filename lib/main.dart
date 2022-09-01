//TODO widget
//TODO fix compatibility web/ios
//TODO comments

import 'package:ezstudies/agenda/agenda.dart';
import 'package:ezstudies/homeworks/homeworks.dart';
import 'package:ezstudies/search/search.dart';
import 'package:ezstudies/settings/Settings.dart';
import 'package:ezstudies/utils/notifications.dart';
import 'package:ezstudies/utils/preferences.dart';
import 'package:ezstudies/utils/secret.dart';
import 'package:ezstudies/utils/style.dart';
import 'package:ezstudies/welcome/welcome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  await Future.delayed(const Duration(milliseconds: 100)); // temporary fix
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.accentColor;
  await Preferences.load();
  await Secret.load();
  await Style.load();
  await Notifications.initNotifications();
  runApp(const EzStudies());
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
        debugShowCheckedModeBanner: false,
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
        home: ((Preferences.sharedPreferences.getString("name") ?? "")
                    .isNotEmpty &&
                (Preferences.sharedPreferences.getString("password") ?? "")
                    .isNotEmpty)
            ? Main(
                reloadTheme: () => setState(() {}),
              )
            : const Welcome());
  }
}

class Main extends StatefulWidget {
  const Main({required this.reloadTheme, Key? key}) : super(key: key);
  final Function reloadTheme;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int selectedIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets;
    List<BottomNavigationBarItem> items;
    if (kIsWeb) {
      widgets = <Widget>[
        const Agenda(agenda: true),
        const Search(),
        Settings(reloadTheme: () => setState(() => widget.reloadTheme())),
      ];
      items = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: getIcon(0),
          label: AppLocalizations.of(context)!.agenda,
        ),
        BottomNavigationBarItem(
          icon: getIcon(1),
          label: AppLocalizations.of(context)!.search,
        ),
        BottomNavigationBarItem(
          icon: getIcon(3),
          label: AppLocalizations.of(context)!.settings,
        ),
      ];
    } else {
      widgets = <Widget>[
        const Agenda(agenda: true),
        const Search(),
        const Homeworks(),
        Settings(reloadTheme: () => setState(() => widget.reloadTheme())),
      ];
      items = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: getIcon(0),
          label: AppLocalizations.of(context)!.agenda,
        ),
        BottomNavigationBarItem(
          icon: getIcon(1),
          label: AppLocalizations.of(context)!.search,
        ),
        BottomNavigationBarItem(
          icon: getIcon(2),
          label: AppLocalizations.of(context)!.homeworks,
        ),
        BottomNavigationBarItem(
          icon: getIcon(3),
          label: AppLocalizations.of(context)!.settings,
        ),
      ];
    }
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) => setState(() => selectedIndex = index),
        children: widgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          onTap: (value) => pageController.animateToPage(value,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut)),
    );
  }

  Widget getIcon(int index) {
    const List<IconData> icons = <IconData>[
      Icons.view_agenda_outlined,
      Icons.search_outlined,
      Icons.library_books_outlined,
      Icons.settings_outlined
    ];

    const List<IconData> iconsSelected = <IconData>[
      Icons.view_agenda,
      Icons.search,
      Icons.library_books,
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
}
