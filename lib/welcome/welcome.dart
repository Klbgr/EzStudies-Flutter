import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:ms_undraw/ms_undraw.dart';

import '../config/env.dart';
import '../main.dart';
import '../utils/cipher.dart';
import '../utils/preferences.dart';
import '../utils/style.dart';
import '../utils/templates.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int selectedIndex = 0;
  final PageController pageController = PageController(initialPage: 0);
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Curve animationCurve = Curves.easeInOut;
  final TextStyle textStyle = TextStyle(color: Style.text, fontSize: 16);
  String name = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      WelcomePageTemplate(
          content: Text(AppLocalizations.of(context)!.welcome_welcome,
              style: textStyle, textAlign: TextAlign.center),
          illustration: UnDrawIllustration.welcoming),
      WelcomePageTemplate(
          content: Text(AppLocalizations.of(context)!.welcome_features,
              style: textStyle, textAlign: TextAlign.center),
          illustration: UnDrawIllustration.features_overview),
      WelcomePageTemplate(
          content:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(AppLocalizations.of(context)!.welcome_login,
                style: textStyle, textAlign: TextAlign.center),
            Container(
                margin: const EdgeInsets.only(bottom: 10, top: 20),
                child: TextFormFieldTemplate(
                    label: AppLocalizations.of(context)!.name,
                    icon: Icons.person,
                    onChanged: (value) => name = value)),
            TextFormFieldTemplate(
                label: AppLocalizations.of(context)!.password,
                icon: Icons.password,
                onChanged: (value) => password = value,
                hidden: true)
          ]),
          illustration: UnDrawIllustration.login)
    ];

    Widget child = Stack(children: [
      PageView(
        onPageChanged: (value) {
          name = "";
          password = "";
          setState(() => selectedIndex = value);
        },
        controller: pageController,
        children: buildPages(pages),
      ),
      Container(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildDots(pages.length)))
    ]);

    return Template(
        title: AppLocalizations.of(context)!.welcome,
        back: false,
        child: child);
  }

  void next() {
    pageController.nextPage(duration: animationDuration, curve: animationCurve);
  }

  void previous() {
    pageController.previousPage(
        duration: animationDuration, curve: animationCurve);
  }

  void start() {
    if (name.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialogTemplate(
            title: AppLocalizations.of(context)!.error,
            content: AppLocalizations.of(context)!.error_empty,
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.ok,
                      style: TextStyle(color: Style.primary)))
            ]),
      );
    } else {
      String encryptedName = encrypt(name, Secret.cipher_key);
      String encryptedPassword = encrypt(password, Secret.cipher_key);
      http.post(Uri.parse("${Secret.server_url}api/index.php"),
          body: <String, String>{
            "request": "cyu_check",
            "name": encryptedName,
            "password": encryptedPassword
          }).then((value) {
        if (value.statusCode == 200) {
          if (value.body == "1") {
            Preferences.sharedPreferences
                .setString(Preferences.name, encryptedName)
                .then((value) => Preferences.sharedPreferences
                    .setString(Preferences.password, encryptedPassword)
                    .then((value) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Main(reloadTheme: () {})))));
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                  title: AppLocalizations.of(context)!.error,
                  content: AppLocalizations.of(context)!.error_credentials,
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.ok))
                  ]),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialogTemplate(
                title: AppLocalizations.of(context)!.error,
                content: AppLocalizations.of(context)!.error_internet,
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.ok))
                ]),
          );
        }
      }).catchError((e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialogTemplate(
              title: AppLocalizations.of(context)!.error,
              content: AppLocalizations.of(context)!.error_internet,
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok))
              ]),
        );
      });
    }
  }

  List<Widget> buildPages(List<Widget> widgets) {
    List<Widget> pages = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      List<Widget> children = [widgets[i]];
      if (i == 0 && widgets.length == 1) {
        children.add(WelcomeFABTemplate(begin: true, onPressed: () => start()));
      } else if (i == 0) {
        children.add(WelcomeFABTemplate(next: true, onPressed: () => next()));
      } else if (i == widgets.length - 1) {
        children.add(WelcomeFABTemplate(begin: true, onPressed: () => start()));
        children.add(
            WelcomeFABTemplate(previous: true, onPressed: () => previous()));
      } else {
        children.add(WelcomeFABTemplate(next: true, onPressed: () => next()));
        children.add(
            WelcomeFABTemplate(previous: true, onPressed: () => previous()));
      }
      pages.add(Stack(children: children));
    }
    return pages;
  }

  List<Widget> buildDots(int pageCount) {
    List<Widget> dots = <Widget>[];
    for (int i = 0; i < pageCount; i++) {
      dots.add(GestureDetector(
          child: Icon(
              (selectedIndex == i) ? Icons.circle : Icons.circle_outlined,
              size: 10,
              color: Style.text),
          onTap: () => pageController.animateToPage(i,
              duration: animationDuration, curve: animationCurve)));
    }
    return dots;
  }
}
