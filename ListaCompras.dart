import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<ListaDeCompras>> fetchListaDeCompras() async {
  final response =
      await http.get(Uri.parse('https://arquivos.ectare.com.br/listadecompras.json'));

  if (response.statusCode == 200) {
    return (json.decode(utf8.decode(response.bodyBytes)) as List)
        .map((i) => ListaDeCompras.fromJson(i))
        .toList();
  } else {
    throw Exception('Failed to load ListaDeCompras');
  }
}

class ListaDeCompras {
  final String item;
  final int quantidade;
  final String unidade; // Ajustado para string
  final double preco;

  ListaDeCompras({
    required this.item,
    required this.quantidade,
    required this.unidade,
    required this.preco,
  });

  factory ListaDeCompras.fromJson(Map<String, dynamic> json) {
    return ListaDeCompras(
      item: json['item'],
      quantidade: json['quantidade'],
      unidade: json['unidade'], // Ajustado para string
      preco: json['preco'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<ListaDeCompras>> futureListaDeCompras;

  @override
  void initState() {
    super.initState();
    futureListaDeCompras = fetchListaDeCompras();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Lista de Compras',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: FutureBuilder<List<ListaDeCompras>>(
              future: futureListaDeCompras,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Erro: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  );
                } else {
                  final data = snapshot.data!;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blueAccent),
                          dataRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white),
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Item',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Quantidade',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Unidade',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Preço',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: data
                              .map(
                                (listaDeCompras) => DataRow(
                                  cells: [
                                    DataCell(Text(
                                      listaDeCompras.item,
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    DataCell(Text(
                                      listaDeCompras.quantidade.toString(),
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    DataCell(Text(
                                      listaDeCompras.unidade,
                                      style: TextStyle(fontSize: 14),
                                    )),
                                    DataCell(Text(
                                      listaDeCompras.preco.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic),
                                    )),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}