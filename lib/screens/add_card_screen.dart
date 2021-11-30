import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/utils/deepl_lang.dart';
import 'package:zxzc9992/utils/keys.dart';
import 'package:zxzc9992/widgets/add_card_form.dart';
import 'package:http/http.dart' as http;

class AddCardScreen extends StatefulWidget {
  static const routeName = '/add-card';

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isInit = true;
  bool _isLoading = false;

  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  File? _frontImg;
  File? _backImg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final cardId = ModalRoute.of(context)?.settings.arguments as String?;

      if (cardId != null) {
        final cardsProvider = Provider.of<CardsProvider>(
          context,
          listen: false,
        );

        final currentCard = cardsProvider.currentCards.firstWhere(
          (e) => e.id == cardId,
        );

        final regExp = RegExp(r"<[^>]+>");
        final unescape = HtmlUnescape();

        final frontPlain = currentCard.front.replaceAll(regExp, '');
        final backPlain = currentCard.back.replaceAll(regExp, '');

        _frontController.text = unescape.convert(frontPlain);
        _backController.text = unescape.convert(backPlain);

        _frontImg = currentCard.frontImg;
        _backImg = currentCard.backImg;
      }
    }

    _isInit = false;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final cardId = ModalRoute.of(context)?.settings.arguments as String?;
    final cardsProvider = Provider.of<CardsProvider>(context, listen: false);

    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (cardId != null) {
      await cardsProvider.editCard(
        id: cardId,
        front: front,
        back: back,
        frontImg: _frontImg,
        backImg: _backImg,
      );
      Navigator.of(context).pop();
    } else {
      print(_frontImg?.path);
      await cardsProvider.addCard(
        front: front,
        back: back,
        frontImg: _frontImg,
        backImg: _backImg,
      );
      _frontController.text = '';
      _backController.text = '';
      _frontImg = null;
      _backImg = null;
    }

    setState(() => _isLoading = false);
  }

  void _translate(bool isFront, String text) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set a source language',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (ctx, i) =>
                      ListTile(title: Text(deeplLangList[i].long)),
                  itemCount: deeplLangList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // final front = _frontController.text;
    // final back = _backController.text;
    // if (isFront) {
    //   final url = Uri.parse('$deepl&text=$back&target_lang=de');
    //   final res = await http.post(url);
    //   final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    //   print(decoded["translations"]);
    //   _frontController.text = decoded["translations"][0]["text"] as String;
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _frontController.dispose();
    _backController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardId = ModalRoute.of(context)?.settings.arguments as String?;
    final cardsProvider = Provider.of<CardsProvider>(context, listen: false);

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(cardId == null ? 'Add a card' : 'Edit card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 28),
            onPressed: () async {
              if (_isLoading) return;

              if (cardId != null) await cardsProvider.deleteCard(cardId);
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.done_rounded, size: 28),
            onPressed: !_isLoading ? _saveForm : null,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(children: [
              AddCardForm(
                labelText: 'Front',
                controller: _frontController,
                img: _frontImg,
                addPhoto: (File file) {
                  setState(() {
                    _frontImg = file;
                  });
                },
                translate: () => _translate(true, _backController.text),
              ),
              IconButton(
                icon: Icon(Icons.sync_alt_rounded, color: Colors.grey[500]),
                onPressed: () {
                  final data = _frontController.text;
                  _frontController.text = _backController.text;
                  _backController.text = data;
                },
              ),
              AddCardForm(
                labelText: 'Back',
                controller: _backController,
                img: _backImg,
                addPhoto: (File file) {
                  setState(() {
                    _backImg = file;
                  });
                },
                translate: () => _translate(false, _frontController.text),
              ),
              //const Spacer(),
              // TextButton(
              //   child: Text(
              //     'Source language - Target language',
              //     style: TextStyle(color: Colors.grey[300]),
              //   ),
              //   onPressed: () {},
              // )
            ]),
          ),
        ),
      ),
    );
  }
}
