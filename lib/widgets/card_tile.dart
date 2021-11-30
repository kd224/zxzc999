import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/screens/add_card_screen.dart';

enum PopupMenuAction {
  edit,
  reset,
  delete,
}

class CardTile extends StatelessWidget {
  final String id;
  final String front;
  final String back;

  final File? frontImg;

  final int interval;
  final int grade;
  final int repetitions;
  final double ef;

  const CardTile({
    required this.id,
    required this.front,
    required this.back,
    this.frontImg,
    required this.repetitions,
    required this.ef,
    required this.grade,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardsProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
      //margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).backgroundColor),
        ),
        //border: Border.all(color: Theme.of(context).backgroundColor),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor,
        //     spreadRadius: 1,
        //     blurRadius: 1,
        //     offset: const Offset(0, 1),
        //   ),
        // ],
        //borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(
                  front,
                  textStyle: const TextStyle(fontSize: 16),
                  customStylesBuilder: (el) {
                    if (el.localName == 'strong') {
                      return {'font-weight': '600'};
                    }
                  },
                ),
                const SizedBox(height: 3),
  
                HtmlWidget(
                  back,
                  textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  customStylesBuilder: (el) {
                    //return {'color': 'grey',};
                    if (el.localName == 'strong') {
                      return {'font-weight': '600'};
                    }
                  },
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 22,
              color: Theme.of(context).iconTheme.color,
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(
                child: Text('Edit'),
                value: PopupMenuAction.edit,
              ),
              PopupMenuItem(
                child: Text('Reset progress'),
                value: PopupMenuAction.reset,
              ),
              PopupMenuItem(
                child: Text('Delete'),
                value: PopupMenuAction.delete,
              ),
            ],
            onSelected: (PopupMenuAction action) async {
              if (action == PopupMenuAction.edit) {
                Navigator.of(context).pushNamed(
                  AddCardScreen.routeName,
                  arguments: id,
                );

                return;
              }

              if (action == PopupMenuAction.reset) {
                cardProvider.resetProgress(id);
                return;
              }

              if (action == PopupMenuAction.delete) {
                cardProvider.deleteCard(id);
                return;
              }
            },
          ),
        ],
      ),
    );

    // Container(
    //   decoration: BoxDecoration(
    //     border: Border(
    //       bottom: BorderSide(color: Theme.of(context).backgroundColor),
    //     ),
    //   ),
    //   child: ListTile(
    //     leading: Container(
    //       height: 30,
    //       width: 4,
    //       decoration: BoxDecoration(
    //         color: _levelAssigner(),
    //         borderRadius: BorderRadius.circular(5),
    //       ),
    //     ),
    //     title: Text(front),
    //     subtitle: Text(back),
    //     trailing: PopupMenuButton(
    //       icon: Icon(
    //         Icons.more_vert_rounded,
    //         size: 22,
    //         color: Colors.grey[300],
    //       ),
    //       itemBuilder: (_) => const [
    //         PopupMenuItem(
    //           child: Text('Edit'),
    //           value: PopupMenuAction.edit,
    //         ),
    //         PopupMenuItem(
    //           child: Text('Reset progress'),
    //           value: PopupMenuAction.reset,
    //         ),
    //         PopupMenuItem(
    //           child: Text('Delete'),
    //           value: PopupMenuAction.delete,
    //         ),
    //       ],
    //       onSelected: (PopupMenuAction action) async {
    //         if (action == PopupMenuAction.edit) {
    //           Navigator.of(context).pushNamed(
    //             AddCardScreen.routeName,
    //             arguments: id,
    //           );

    //           return;
    //         }

    //         if (action == PopupMenuAction.reset) {
    //           cardProvider.resetProgress(id);
    //           return;
    //         }

    //         if (action == PopupMenuAction.delete) {
    //           cardProvider.deleteCard(id);
    //           return;
    //         }
    //       },
    //     ),
    //   ),
    // );
  }
}
