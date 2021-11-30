// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:http/http.dart' as http;
// import 'package:zxzc9992/utils/keys.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart' as p;

// class ImageSearchScreen extends StatefulWidget {
//   @override
//   State<ImageSearchScreen> createState() => _ImageSearchScreenState();
// }

// class _ImageSearchScreenState extends State<ImageSearchScreen> {
//   bool _isLoading = false;

//   List<String> _images = [];

//   Future<void> _fetchImages(String query) async {
//     setState(() => _isLoading = true);
//     _images = [];

//     final apiKey = 'https://api.pexels.com/v1/search?query=$query&per_page=10';
//     const headers = {'Authorization': pexelsKey};
//     final url = Uri.parse(apiKey);

//     final res = await http.get(url, headers: headers);

//     final decoded = jsonDecode(res.body) as Map<String, dynamic>;
//     print(decoded);
//     for (final data in decoded['photos']) {
//       _images.add(data['src']['medium'] as String);
//     }
//     setState(() => _isLoading = false);
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search_rounded),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.clear_rounded),
//                   onPressed: () {},
//                 ),
//               ),
//               onFieldSubmitted: (String val) {
//                 _fetchImages(val);
//               },
//             ),
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Expanded(
//                     child: GridView.builder(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 3 / 2,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                       ),
//                       itemCount: _images.length,
//                       itemBuilder: (ctx, i) => ImageTile(
//                         imageUrl: _images[i],
//                       ),
//                     ),
//                   )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ImageTile extends StatelessWidget {
//   const ImageTile({Key? key, required this.imageUrl}) : super(key: key);

//   final String imageUrl;

//   @override
//   Widget build(BuildContext context) {
//     final cachedNetworkImage = CachedNetworkImageProvider(imageUrl);

//     final img = Image(
//       image: cachedNetworkImage,
//       loadingBuilder: (ctx, child, progress) {
//         return progress == null
//             ? child
//             : LinearProgressIndicator(color: Colors.grey[300]);
//       },
//       fit: BoxFit.cover,
//     );

//     return GestureDetector(
//       child: img,
//       onTap: () async {
//         // Directory docDir = await p.getApplicationDocumentsDirectory();
//         // File file = new File(join(documentDirectory.path, 'imagetest.png'));

//         final res = await showDialog<bool>(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             content: img,
//             actions: [
//               TextButton(
//                 child: const Text('CANCEL'),
//                 onPressed: () {
//                   Navigator.of(ctx).pop(false);
//                 },
//               ),
//               TextButton(
//                 child: const Text('ADD'),
//                 onPressed: () async {
//                   Navigator.of(context).pop(true);
//                 },
//               ),
//             ],
//           ),
//         );

//         if (res == true) {
//           Directory appDir = await p.getApplicationDocumentsDirectory();

//           final file = await DefaultCacheManager().getSingleFile(imageUrl);
//           final fileName = basename(file.path);

//           final savedImage = await file.copy('${appDir.path}/$fileName');
//           print(savedImage.path);
//         }
//       },
//     );
//   }
// }
