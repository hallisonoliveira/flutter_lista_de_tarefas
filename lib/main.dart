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

	final _toDoController = TextEditingController();

	// Lista com as tarefas
	List _toDoList = [];
	Map<String, dynamic> _lastRemoved;
	int _lastRemovedPos;

	@override
	void initState() {
		super.initState();

		_readData().then((data) {
			setState(() {
				_toDoList = json.decode(data);
			});
		});
	}

	// Adiciona um novo item na lista
	void _addToDo() {
		setState(() {
			Map<String, dynamic> newToDo = Map();
			newToDo["title"] = _toDoController.text;
			_toDoController.text = "";
			newToDo["ok"] = false;
			_toDoList.add(newToDo);

			_saveData();
		});
	}

	Future<Null> _refresh() async {
		await Future.delayed(Duration(seconds: 1));

		setState(() {
			_toDoList.sort((a, b) {
				if (a["ok"]  && !b["ok"]) return 1;
				else if (!a["ok"]  && b["ok"]) return -1;
				else return 0;
			});

			_saveData();
		});
	}

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
										controller: _toDoController,
									)
								),
								RaisedButton(
									color: Colors.blueAccent,
									child: Text("Adicionar"),
									textColor: Colors.white,
									onPressed: _addToDo,
								),
							],
						),
					),
					Expanded(
						child: RefreshIndicator(
							onRefresh: _refresh,
							child:  ListView.builder(
								padding: EdgeInsets.all(0.0),
								itemCount: _toDoList.length,
								itemBuilder: buildItem
							),
						),
					)
				],
			),
		);
	}
	
	// Responsavel por montar cada item da lista
	Widget buildItem(context, index) {
		// Widget para o arrastar e remover
		return Dismissible(
			key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
			background: Container(
				color: Colors.red,
				child: Align(
					alignment: Alignment(-0.9, 0.0),
					child: Icon(Icons.delete, color: Colors.white,),
				),
			),
			direction: DismissDirection.startToEnd,
			child: CheckboxListTile(
				title: Text(_toDoList[index]["title"]),
				value: _toDoList[index]["ok"],
				secondary: CircleAvatar(
					child: Icon(
						_toDoList[index]["ok"] ? Icons.check : Icons.error),
				),
				onChanged: (check){
					setState(() {
						_toDoList[index]["ok"] = check;
						_saveData();
					});
				},
			),
			onDismissed: (direction) {
				setState(() {
					_lastRemoved = Map.from(_toDoList[index]);
					_lastRemovedPos = index;
					_toDoList.removeAt(index);

					_saveData();

					final snack = SnackBar(
						content: Text("Tarefa \"${_lastRemoved["title"]}\" removida."),
						action: SnackBarAction(
							label: "Desfazer",
							onPressed: () {
								setState(() {
									_toDoList.insert(_lastRemovedPos, _lastRemoved);
									_saveData();
								});
							}),
						duration: Duration(seconds: 5),
					);
					Scaffold.of(context).removeCurrentSnackBar();
					Scaffold.of(context).showSnackBar(snack);
				});

			},
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
