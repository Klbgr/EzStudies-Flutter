import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:ms_undraw/ms_undraw.dart';

import '../main.dart';
import '../utils/cipher.dart';
import '../utils/preferences.dart';
import '../utils/secret.dart';
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
  final TextStyle textStyle = TextStyle(color: Style.text, fontSize: 24);
  String name = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    Widget page1 = WelcomePageTemplate(
        Text(AppLocalizations.of(context)!.welcome_welcome,
            style: textStyle, textAlign: TextAlign.center),
        UnDrawIllustration.welcoming);

    Widget page2 = WelcomePageTemplate(
        Text(AppLocalizations.of(context)!.welcome_features,
            style: textStyle, textAlign: TextAlign.center),
        UnDrawIllustration.features_overview);

    Widget page3 = WelcomePageTemplate(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(AppLocalizations.of(context)!.welcome_login,
              style: textStyle, textAlign: TextAlign.center),
          Container(
              margin: const EdgeInsets.only(bottom: 10, top: 20),
              child: TextFormFieldTemplate(
                  AppLocalizations.of(context)!.name, Icons.person,
                  onChanged: (value) => name = value)),
          TextFormFieldTemplate(
              AppLocalizations.of(context)!.password, Icons.password,
              onChanged: (value) => password = value, hidden: true)
        ]),
        UnDrawIllustration.login);

    List<Widget> pages = [page1, page2, page3];

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

    return Template(AppLocalizations.of(context)!.welcome, child, back: false);
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
        builder: (context) =>
            AlertDialogTemplate(AppLocalizations.of(context)!.error, "empty", [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Style.primary)))
        ]),
      );
    } else {
      String encryptedName = encrypt(name, Secret.cipherKey);
      String encryptedPassword = encrypt(password, Secret.cipherKey);
      http.post(Uri.parse(Secret.serverUrl), body: <String, String>{
        "request": "cyu_check",
        "name": encryptedName,
        "password": encryptedPassword
      }).then((value) {
        if (value.statusCode == 200) {
          if (value.body == "1") {
            Preferences.sharedPreferences.setString("name", encryptedName).then(
                (value) => Preferences.sharedPreferences
                    .setString("password", encryptedPassword)
                    .then((value) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Main(reloadTheme: () {})))));
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialogTemplate(
                  AppLocalizations.of(context)!.error,
                  AppLocalizations.of(context)!.error_credentials, [
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
                AppLocalizations.of(context)!.error,
                AppLocalizations.of(context)!.error_internet, [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.ok))
            ]),
          );
        }
      }).catchError((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialogTemplate(
              AppLocalizations.of(context)!.error,
              AppLocalizations.of(context)!.error_internet, [
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
