import 'dart:convert';
import 'package:buscador_gif/UI/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variável que guarda o texto da busca (tem que inicializar para evitar erro)
  late String _search = '';

  // Variável para a paginação (offset)
  int _offset = 0;

  // Função assíncrona para buscar GIFs
  Future<Map> _getGifs() async {
    http.Response response;

    if (_search.isEmpty) {
      // Se não há busca, pega GIFs populares (trending)
      response = await http.get(
        Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=yv3kzftKe70Ewyc8SOA4YjVUP0tSxApI&limit=20&offset=$_offset&rating=g&bundle=messaging_non_clip",
        ),
      );
    } else {
      // Se há busca, procura GIFs relacionados ao termo _search
      response = await http.get(
        Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=yv3kzftKe70Ewyc8SOA4YjVUP0tSxApI&q=$_search&limit=19&offset=$_offset&rating=g&lang=en",
        ),
      );
    }

    // Decodifica o JSON para um Map e retorna
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif",
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Buscar GIFs",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (text) {
                setState(() {
                  _search = text;
                  _offset = 0; // Quando mudar busca, zera o offset
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  late List gifs;

  int _getCont(List data) {
    if (_search.isEmpty) {
      return gifs.length;
    } else {
      return gifs.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    gifs = snapshot.data["data"]; // Pega a lista de GIFs

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 10.0, // Espaço horizontal
        mainAxisSpacing: 10.0, // Espaço vertical
      ),
      itemCount: _getCont(gifs), // <- Agora usa o tamanho da lista!
      itemBuilder: (context, index) {
        if (_search.isEmpty || index < snapshot.data["data"].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: gifs[index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data["data"][index]),
                ),
              );
            },
          );
        } else {
          return GestureDetector(
            child: Container(
              color: Colors.black26,
              child: const Center(
                // Centraliza totalmente
                child: Icon(Icons.add, color: Colors.white, size: 70.0),
              ),
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          );
        }
      },
    );
  }
}
