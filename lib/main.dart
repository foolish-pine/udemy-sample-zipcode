import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _items = [];
  String _errorMessage = '';

  Future<void> loadZipCode(String zipCode) async {
    setState(() {
      _errorMessage = 'APIレスポンス待ち';
    });

    final response = await http.get(
        Uri.parse('https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode'));

    if (response.statusCode != 200) {
      setState(() {
        _errorMessage = '郵便番号の取得に失敗しました';
      });
      return;
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final results = (body['results'] ?? []) as List<dynamic>;

    if (results.isEmpty) {
      setState(() {
        _errorMessage = 'そのような郵便番号の住所はありません';
      });
    } else {
      setState(() {
        _errorMessage = '';
        _items = results
            .map((result) =>
                "${result["address1"]}${result["address2"]}${result["address3"]}")
            .toList(growable: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) loadZipCode(value);
            },
          ),
          _errorMessage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_items[index]),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
