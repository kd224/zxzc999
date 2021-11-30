import 'package:flutter/material.dart';

class CardsPerGameDialog extends StatefulWidget {
  final int cardsAmount;
  //final Function onPress;

  const CardsPerGameDialog(this.cardsAmount);


  @override
  State<CardsPerGameDialog> createState() => _CardsPerGameDialogState();
}

class _CardsPerGameDialogState extends State<CardsPerGameDialog> {
  int cardsPerGame = 25;

  @override
  void initState() {
    super.initState();
    cardsPerGame = widget.cardsAmount;
  }



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Set max. cards per game"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.replay_5, size: 26),
            onPressed: () {
              setState(() {
                cardsPerGame > 5 ? cardsPerGame -= 5 : cardsPerGame = 5;
              });
            },
          ),
          Text(
            cardsPerGame.toString(),
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.forward_5_rounded, size: 26),
            onPressed: () {
              setState(() {
                cardsPerGame += 5;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: const Text('Submit'),
          onPressed: () {
            Navigator.of(context).pop(cardsPerGame);
          },
        ),
      ],
    );
  }
}
