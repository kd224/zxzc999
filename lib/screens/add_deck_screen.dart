import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/decks_provider.dart';
import 'package:zxzc9992/utils/deepl_lang.dart';

class AddDeckScreen extends StatefulWidget {
  static const routeName = '/add-deck';

  @override
  _AddDeckScreenState createState() => _AddDeckScreenState();
}

class _AddDeckScreenState extends State<AddDeckScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isInit = true;
  bool _isLoading = false;
  //bool _showAdditOptions = false;

  final _titleController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final deckId = ModalRoute.of(context)?.settings.arguments as String?;
      if (deckId != null) {
        final deck = Provider.of<DecksProvider>(context, listen: false);

        _titleController.text = deck.currentDeck.title;
      }
    }

    _isInit = false;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final deckId = ModalRoute.of(context)?.settings.arguments as String?;
    final decksProvider = Provider.of<DecksProvider>(context, listen: false);

    if (deckId != null) {
      await decksProvider.editDeck(deckId, _titleController.text.trim());
    } else {
      await decksProvider.addDeck(_titleController.text.trim());
    }

    setState(() => _isLoading = false);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final deckId = ModalRoute.of(context)?.settings.arguments as String?;

    BoxDecoration _containerStyle(BuildContext context, Color col) {
      return BoxDecoration(
        color: col,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      );
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(deckId == null ? 'Add a deck' : 'Edit a deck')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.create_new_folder_outlined, size: 30),
              const SizedBox(height: 10),
              const Text('Select a title for\nyour deck',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              AddDeckTextField(titleController: _titleController),
              // ListTile(
              //   title: const Text('Additional options'),
              //   trailing: _showAdditOptions
              //       ? const Icon(Icons.expand_less_rounded)
              //       : const Icon(Icons.expand_more_rounded),
              //   onTap: () {
              //     setState(() => _showAdditOptions = !_showAdditOptions);
              //   },
              // ),
              // if (_showAdditOptions)
              //   Container(
              //     margin: const EdgeInsets.symmetric(horizontal: 20),
              //     decoration: BoxDecoration(
              //         border: Border.all(color: Colors.grey),
              //         borderRadius: BorderRadius.circular(5)),
              //     child: Column(
              //       children: [
              //         DeeplLanguageOptions(title: 'Your language'),
              //         DeeplLanguageOptions(title: 'Target language'),
              //       ],
              //     ),
              //   ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: _containerStyle(context, Colors.blue[300]!),
                child: TextButton(
                  child: _isLoading
                      ? SizedBox(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color?>(
                              Colors.blue[300],
                            ),
                            strokeWidth: 3,
                          ),
                          height: 20,
                          width: 20,
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                  onPressed: _saveForm,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DeeplLanguageOptions extends StatelessWidget {
  final String title;

  const DeeplLanguageOptions({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Text('Polish'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Container(
              height: 300,
              width: 300,
              child: ListView.builder(
                itemCount: deeplLangList.length,
                itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextButton(
                      child: Text(deeplLangList[i].long),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddDeckTextField extends StatelessWidget {
  const AddDeckTextField({
    Key? key,
    required TextEditingController titleController,
  })  : _titleController = titleController,
        super(key: key);

  final TextEditingController _titleController;

  BoxDecoration _containerStyle(BuildContext context, Color col) {
    return BoxDecoration(
      color: col,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor,
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
      borderRadius: BorderRadius.circular(25),
    );
  }

  OutlineInputBorder _textFieldBorder(Color col) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: col),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _containerStyle(context, Theme.of(context).canvasColor),
      child: TextFormField(
        autocorrect: false,
        enableSuggestions: false,
        maxLength: 50,
        decoration: InputDecoration(
          labelText: 'Enter a title...',
          counterText: "",
          focusColor: Colors.grey[200],
          labelStyle: TextStyle(color: Colors.grey[500]),
          focusedBorder: _textFieldBorder(Colors.transparent),
          enabledBorder: _textFieldBorder(Colors.transparent),
        ),
        controller: _titleController,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Deck title is required';
          }

          if (val.length > 150) {
            return 'Max. length of deck title is 150 characters';
          }

          return null;
        },
      ),
    );
  }
}
