import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:zxzc9992/utils/keys.dart';

class AddCardForm extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final File? img;
  final Function addPhoto;
  final Function translate;

  const AddCardForm({
    required this.labelText,
    required this.controller,
    required this.img,
    required this.addPhoto,
    required this.translate,
  });

  OutlineInputBorder _textFieldBorder(Color col) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: col),
    );
  }

  Future<void> _insertPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);

    final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

    final apiKey = Uri.parse(cloudinaryKey);

    print(fileName);
    print(savedImage);

    final request = http.MultipartRequest('POST', apiKey);

    request.fields['upload_preset'] = 'y2tulrkp';
    request.fields['timestamp'] =
        DateTime.now().millisecondsSinceEpoch.toString();

    request.files.add(
      http.MultipartFile(
        'file',
        File(savedImage.path).readAsBytes().asStream(),
        File(savedImage.path).lengthSync(),
        filename: fileName.split("/").last,
      ),
    );
    final res = await request.send();
    print(res.stream);

    addPhoto(savedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: labelText,
              enabledBorder: _textFieldBorder(Colors.transparent),
              focusedBorder: _textFieldBorder(Colors.transparent),
              errorBorder: _textFieldBorder(Colors.red),
              focusedErrorBorder: _textFieldBorder(Colors.red),
            ),
            controller: controller,
            minLines: 3,
            maxLines: 7,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Enter a value';
              }

              if (val.length > 1000) {
                return 'Max. length cannot be higher than 1000 characters';
              }

              return null;
            },
          ),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(Icons.playlist_add_rounded, color: Colors.grey[800]),
              // ),
              // IconButton(
              //   icon: Icon(Icons.translate_rounded, color: Colors.grey[800]),
              //   onPressed: () {
              //     translate();
              //   },
              // ),
              // IconButton(
              //   icon: Icon(
              //     Icons.image_rounded,
              //     color: img != null ? Colors.blue[400] : Colors.grey[800],
              //   ),
              //   //onPressed: _insertPhoto,
              //   onPressed: () {
              //     if (img != null) {
              //       showDialog(
              //         context: context,
              //         builder: (context) => AlertDialog(
              //           content: Image.file(img!),
              //         ),
              //       );

              //       return;
              //     }

              //     _insertPhoto();
              //   },
              // ),
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(Icons.volume_up_rounded, color: Colors.grey[800]),
              // )
            ],
          ),
        ],
      ),
    );
  }
}
