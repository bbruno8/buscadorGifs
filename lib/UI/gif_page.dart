import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;

  GifPage(this._gifData, {super.key});

  void _compartilharLink() {
    final gifUrl = _gifData["images"]?["fixed_height"]?["url"];
    if (gifUrl != null) {
      Share.share(gifUrl, subject: _gifData["title"] ?? 'Confira esse GIF!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gifUrl = _gifData["images"]?["fixed_height"]?["url"];

    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData["title"] ?? 'GIF'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _compartilharLink,
            icon: Icon(Icons.share),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: gifUrl != null
            ? Image.network(gifUrl)
            : Text(
          "Imagem não disponível",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
