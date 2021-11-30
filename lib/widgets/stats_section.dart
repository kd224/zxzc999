import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zxzc9992/utils/keys.dart';

class StatsSection extends StatelessWidget {
  final box = Hive.box(flashcardsStatsBox);

  //final List<String> _weekDays = ['m', 't', 'w', 't', 'f', 's', 's'];
  final List<Widget> _list = [];

  @override
  Widget build(BuildContext context) {
    //final data = box.get(flashcardsReviewCounterKey);

    // for (int i = 0; i <= 6; i++) {
    //   _list.add(StatsBar(
    //     weekday: _weekDays[i],
    //     counter: data[i],
    //   ));
    // }

    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _list,
      ),
    );
  }
}

class StatsBar extends StatelessWidget {
  final String weekday;
  final int counter;

  const StatsBar({
    required this.weekday,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(weekday.toString()),
        Text(counter.toString()),
      ],
    );
  }
}
