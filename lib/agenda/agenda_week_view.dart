import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/style.dart';
import '../utils/templates.dart';
import '../utils/timestamp_utils.dart';
import 'agenda_cell_data.dart';
import 'agenda_week_view_cell.dart';

class AgendaWeekView extends StatefulWidget {
  const AgendaWeekView({required this.data, super.key});
  final List<AgendaCellData> data;

  @override
  State<AgendaWeekView> createState() => _AgendaWeekViewState();
}

class _AgendaWeekViewState extends State<AgendaWeekView> {
  List<DateTime> firstDayOfWeeks = [];
  PageController controller = PageController();
  int selectedPage = 0;
  List<Widget> pages = [];
  List<String> dayNames = [];
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      init();
    }

    Column child = Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              icon: Icon(Icons.chevron_left_rounded,
                  color: (pages.isEmpty || selectedPage == 0)
                      ? Style.hint
                      : Style.text)),
          Text(firstDayOfWeeks.isEmpty
              ? AppLocalizations.of(context)!.nothing_to_show
              : "${AppLocalizations.of(context)!.week_of} ${timestampToDayMonthYear(firstDayOfWeeks[selectedPage].millisecondsSinceEpoch)}"),
          IconButton(
              onPressed: () => controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              icon: Icon(Icons.chevron_right_rounded,
                  color: (pages.isEmpty || selectedPage == pages.length - 1)
                      ? Style.hint
                      : Style.text))
        ],
      ),
      Expanded(
          child: PageView(
        controller: controller,
        children: pages,
        onPageChanged: (value) => setState(() {
          selectedPage = value;
        }),
      ))
    ]);

    return Template(
        title: AppLocalizations.of(context)!.week_view,
        back: true,
        compact: true,
        child: child);
  }

  void init() {
    dayNames = [
      AppLocalizations.of(context)!.monday,
      AppLocalizations.of(context)!.tuesday,
      AppLocalizations.of(context)!.wednesday,
      AppLocalizations.of(context)!.thursday,
      AppLocalizations.of(context)!.friday,
      AppLocalizations.of(context)!.saturday,
      AppLocalizations.of(context)!.sunday
    ];
    generatePages();
    int now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < firstDayOfWeeks.length; i++) {
      if (firstDayOfWeeks[i].millisecondsSinceEpoch > now) {
        selectedPage = i-1;
        if (selectedPage < 0) {
          selectedPage = 0;
        }
        controller = PageController(initialPage: selectedPage);
        break;
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void generatePages() {
    pages.clear();
    firstDayOfWeeks.clear();
    int index = -1;
    for (int i = 0; i < widget.data.length; i++) {
      int weekDay =
          DateTime.fromMillisecondsSinceEpoch(widget.data[i].start).weekday;
      if (i == 0 ||
          !isSameWeek(widget.data[i - 1].start, widget.data[i].start)) {
        DateTime firstDayOfWeek =
            DateTime.fromMillisecondsSinceEpoch(widget.data[i].start)
                .subtract(Duration(days: weekDay - 1));
        firstDayOfWeeks.add(firstDayOfWeek);
        pages.add(Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Style.hint))),
                child: Row(children: [
                  for (int i = 0; i < dayNames.length; i++)
                    Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(
                                "${dayNames[i]}\n${timestampToDayMonth(firstDayOfWeek.add(Duration(days: i)).millisecondsSinceEpoch)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12))))
                ])),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < dayNames.length; i++)
                            Expanded(
                                child: Column(
                                    children: List.empty(growable: true)))
                        ])))
          ],
        ));
        index++;
      }

      if (weekDay <= dayNames.length) {
        ((((((pages[index] as Column).children[1] as Expanded).child
                            as SingleChildScrollView)
                        .child as Row)
                    .children[weekDay - 1] as Expanded)
                .child as Column)
            .children
            .add(AgendaWeekViewCell(
                data: widget.data[i],
                onOpened: () => SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: SystemUiOverlay.values),
                onClosed: () => SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: [])));
      }
    }
  }
}
