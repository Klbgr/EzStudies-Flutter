import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:ms_undraw/ms_undraw.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';
import '../main.dart';
import '../utils/cipher.dart';
import '../utils/preferences.dart';
import '../utils/templates.dart';
import '../utils/update.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int selectedIndex = 0;
  final PageController pageController = PageController(initialPage: 0);
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Curve animationCurve = Curves.easeInOut;
  final TextStyle textStyle = const TextStyle(fontSize: 16);
  String name = "";
  String password = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      WelcomePageTemplate(
          content: Column(
            children: [
              Text(AppLocalizations.of(context)!.welcome_welcome,
                  style: textStyle, textAlign: TextAlign.center),
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: AppLocalizations.of(context)!.banner_message,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.error,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                                Uri.parse(
                                    "https://github.com/Klbgr/EzStudies-Flutter?tab=readme-ov-file#deprecated"),
                              )),
                  ))
            ],
          ),
          illustration: UnDrawIllustration.welcoming),
      WelcomePageTemplate(
          content: Text(AppLocalizations.of(context)!.welcome_features,
              style: textStyle, textAlign: TextAlign.center),
          illustration: UnDrawIllustration.features_overview),
      Stack(children: [
        WelcomePageTemplate(
            content:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalizations.of(context)!.welcome_login,
                  style: textStyle, textAlign: TextAlign.center),
              Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 20),
                  child: TextFormFieldTemplate(
                      initialValue: name,
                      label: AppLocalizations.of(context)!.name,
                      icon: Icons.person,
                      onChanged: (value) => name = value,
                      autofillHints: const [AutofillHints.username])),
              TextFormFieldTemplate(
                initialValue: password,
                label: AppLocalizations.of(context)!.password,
                icon: Icons.password,
                onChanged: (value) => password = value,
                hidden: true,
                autofillHints: const [AutofillHints.password],
              )
            ]),
            illustration: UnDrawIllustration.login),
        if (loading)
          Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              alignment: Alignment.center,
              child: const CircularProgressIndicator())
      ])
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

  @override
  void initState() {
    super.initState();
    Update.checkUpdate(context);
  }

  void next() {
    pageController.nextPage(duration: animationDuration, curve: animationCurve);
  }

  void previous() {
    pageController.previousPage(
        duration: animationDuration, curve: animationCurve);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void start() {
    setState(() => loading = true);
    if (name.isEmpty || password.isEmpty) {
      setState(() => loading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialogTemplate(
            title: AppLocalizations.of(context)!.error,
            content: AppLocalizations.of(context)!.error_empty,
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.ok))
            ]),
      );
    } else {
      String encryptedName = encrypt(name, Secret.cipher_key);
      String encryptedPassword = encrypt(password, Secret.cipher_key);
      http
          .post(Uri.parse("${Secret.server_url}api/index.php"),
              body: <String, String>{
                "request": "cyu_check",
                "name": encryptedName,
                "password": encryptedPassword
              })
          .catchError((_) => http.Response("", 404))
          .then((response) {
            if (response.statusCode == 200 && response.body == "1") {
              Preferences.sharedPreferences
                  .setString(Preferences.name, encryptedName)
                  .then((value) => Preferences.sharedPreferences
                          .setString(Preferences.password, encryptedPassword)
                          .then((value) {
                        setState(() => loading = false);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EzStudies()));
                      }));
            } else {
              setState(() => loading = false);
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
              color: Theme.of(context).colorScheme.onSurface,
              size: 10),
          onTap: () => pageController.animateToPage(i,
              duration: animationDuration, curve: animationCurve)));
    }
    return dots;
  }
}
