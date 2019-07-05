import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
	runApp(MaterialApp (
		home: Home()
	));
}

class Home extends StatefulWidget {
	@override
	_HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

	// Lista com as tarefas
	List _toDoList = [];

	@override
	Widget build(BuildContext context) {
		return Scaffold (
			appBar: AppBar(
				title: Text("Lista de Tarefas"),
				backgroundColor: Colors.blueAccent,
				centerTitle: true,
			),
			body: Column(
				children: <Widget>[
					Container (
						padding: EdgeInsets.all(16.0),
						child: Row(
							children: <Widget>[
								Expanded(
									child: TextField(
										decoration: InputDecoration(
											labelText: "Nova Tarefa",
											labelStyle: TextStyle(color: Colors.blueAccent)
										),
									)
								),
								RaisedButton(
									color: Colors.blueAccent,
									child: Text("Adicionar"),
									textColor: Colors.white,
									onPressed: (){},
								),
							],
						),
					)
				],
			),
		);
	}

	// Busca o arquivo utilizado para salvar os dados
	Future<File> _getFile() async {
		// Local diferente para Android e iOS
		// PathProvider auxilia nesse ponto
		// await pois o getApplicationDocumentsDirectory retorna um Furure
		final directory = await getApplicationDocumentsDirectory();
		return File("${directory.path}/data.json");
	}

	// Salva os dados no arquivo
	Future<File> _saveData() async {
		String data = json.encode(_toDoList);
		final file = await _getFile();

		// Escreve os dados no formato string no arquivo
		return file.writeAsString(data);
	}

	// Le os dados no arquivo
	Future<String> _readData() async {
		try {
			final file = await _getFile();
			return file.readAsString();
		} catch (e) {
			return null;
		}

	}
}
