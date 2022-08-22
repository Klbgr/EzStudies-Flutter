//TODO welcome page
//TODO celcat api + database
//TODO page info cours
//TODO generation couleur cours
//TODO strings
//TODO mode autre etudiant
//TODO ajout cours perso
//TODO notification
//TODO widget

import 'package:ezstudies/agenda/agenda.dart';
import 'package:ezstudies/search/search.dart';
import 'package:ezstudies/settings/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await Future.delayed(const Duration(milliseconds: 100)); // temporary fix
  runApp(const EzStudies());
}

class EzStudies extends StatelessWidget {
  const EzStudies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget home = const Main();
    return MaterialApp(
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
      home: home,
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int selectedIndex = 0;
  PageController pageController = PageController(initialPage: 0);
  final List<Widget> widgets = <Widget>[
    const Agenda(),
    const Search(),
    const Settings(),
  ];
  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.transparent,
          items: <BottomNavigationBarItem>[
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
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black,
          iconSize: 25,
          unselectedFontSize: 15,
          selectedFontSize: 15,
          onTap: (value) => pageController.animateToPage(value,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut)),
    );
  }

  Icon getIcon(int index) {
    const List<IconData> icons = <IconData>[
      Icons.view_agenda_outlined,
      Icons.search_outlined,
      Icons.settings_outlined
    ];

    const List<IconData> iconsSelected = <IconData>[
      Icons.view_agenda,
      Icons.search,
      Icons.settings
    ];

    if (index == selectedIndex) {
      return Icon(iconsSelected[index]);
    } else {
      return Icon(icons[index]);
    }
  }
}
