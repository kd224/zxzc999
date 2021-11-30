import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/flashcards_provider.dart';

class FlashcardsMain extends StatelessWidget {
  const FlashcardsMain({
    Key? key,
    required this.isVisible,
  }) : super(key: key);

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final flashcards = Provider.of<FlashcardsProvider>(context, listen: false);

    final frontImg = flashcards.currentCard.frontImg;
    final backImg = flashcards.currentCard.backImg;

    return Expanded(
      child: Container(
        //padding: const EdgeInsets.only(bottom: 150, left: 5, right: 5),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        width: double.infinity,

        child: Column(
          children: [
            const SizedBox(height: 60),
            //Image.file(),
            Text(
              flashcards.counter().toString(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[300],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            if (frontImg != null) FlashcardImage(image: frontImg),
            HtmlWidget(
              flashcards.currentCard.front,
              textStyle: const TextStyle(fontSize: 24),
              customStylesBuilder: (el) {
                if (el.localName == 'strong') {
                  return {'font-weight': '600', 'text-align': 'center'};
                }
                return {'text-align': 'center'};
              },
            ),
            // Text(
            //   flashcards.currentCard.front,
            //   textAlign: TextAlign.center,
            //   style: Theme.of(context).textTheme.headline5,
            // ),
            Visibility(
              visible: !isVisible && true,
              child: Container(
                width: 100,
                height: 50,
                child: Divider(
                  thickness: 2,
                  height: 50,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
            ),
            Visibility(
              visible: !isVisible && true,
              child: Column(
                children: [
                  if (backImg != null) FlashcardImage(image: backImg),
                  HtmlWidget(
                    flashcards.currentCard.back,
                    textStyle: const TextStyle(fontSize: 24),
                    customStylesBuilder: (el) {
                      if (el.localName == 'strong') {
                        return {'font-weight': '600', 'text-align': 'center'};
                      }
                      return {'text-align': 'center'};
                    },
                  ),
                  // Text(
                  //   //flashcards.randCard(!flashcards.isFrontFirst)!.back,
                  //   flashcards.currentCard.back,
                  //   textAlign: TextAlign.center,
                  //   style: Theme.of(context).textTheme.headline5,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardImage extends StatelessWidget {
  const FlashcardImage({
    Key? key,
    required this.image,
  }) : super(key: key);

  final File image;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsetsDirectional.all(8),
      child: Image.file(
        image,
        fit: BoxFit.fill,
        height: 300,
      ),
    );
  }
}
