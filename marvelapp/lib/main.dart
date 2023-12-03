import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'square_tile.dart';

Future<Map> fetchMarvelCharacters() async {
  const publicKey = 'fdf6797575776cfa2ecdf01226655261';
  const privateKey = '65a09c6e8f74714f23ee271650015e2909718494';
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final hash =
      md5.convert(utf8.encode(timestamp + privateKey + publicKey)).toString();

  final response = await http.get(
    Uri.parse(
        'https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load characters');
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue[900]),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Marvel Characters'),
          backgroundColor: Colors.red[900],
        ),
        body: FutureBuilder<Map>(
          future: fetchMarvelCharacters(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?['data']['results'].length,
                itemBuilder: (context, index) {
                  var character = snapshot.data?['data']['results'][index];
                  return SquareTile(
                    name: character['name'],
                    description: character['description'],
                    imagePath: '${character['thumbnail']['path']}.jpg',
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
