import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Template extends StatelessWidget {
  const Template(this.title, this.child, this.menu, this.back, {Key? key})
      : super(key: key);
  final String title;
  final Widget child;
  final Widget? menu;
  final bool back;

  @override
  Widget build(BuildContext context) {
    IconButton? iconButton;
    if (back) {
      iconButton = IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      );
    }
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          actions: (menu == null) ? null : [menu!],
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: iconButton,
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 20, bottom: 20),
              child: Text(
                title,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: child,
            )
          ],
        ));
  }
}

class MenuTemplate extends StatelessWidget {
  const MenuTemplate(this.items, this.onSelected, {Key? key}) : super(key: key);
  final List<PopupMenuItem<String>> items;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
      itemBuilder: (BuildContext context) {
        return items;
      },
      onSelected: (value) {
        onSelected(value);
      },
    );
  }
}

class OpenContainerTemplate extends StatelessWidget {
  OpenContainerTemplate(this.child1, this.child2, this.onClosed, {Key? key})
      : super(key: key);
  final Widget child1;
  final Widget child2;
  final Function onClosed;
  Function trigger = () {};

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.white,
      closedElevation: 0,
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, action) {
        trigger = action;
        return child1;
      },
      openBuilder: (context, action) => child2,
      onClosed: (_) => onClosed(),
    );
  }

  Function getTrigger() {
    return trigger;
  }
}

class AlertDialogTemplate extends StatelessWidget {
  const AlertDialogTemplate(this.title, this.content, this.actions, {Key? key})
      : super(key: key);
  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title), content: Text(content), actions: actions);
  }
}
