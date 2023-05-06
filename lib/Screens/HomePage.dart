import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:simple_todo_mysql/Model/Todo.dart';

class MySQLToDoList extends StatefulWidget {
  const MySQLToDoList({Key? key}) : super(key: key);

  @override
  State<MySQLToDoList> createState() => _MySQLToDoListState();
}

List<Todo> data = [];
ConnectionSettings connectionString = ConnectionSettings(
  // ...
);

class _MySQLToDoListState extends State<MySQLToDoList> {
  @override
  void initState() {
    super.initState();
    connectMysql();
  }

  Future<void> connectMysql() async {
    final conn = await MySqlConnection.connect(connectionString);
    var results = await conn.query("SELECT * FROM todo");
    debugPrint(results.toString());
    List<Todo> tempData = [];

    for (var row in results) {
      tempData.add(Todo(
        id: row['id'],
        title: row['title'],
        iscomplated: row['iscomplated'] == 1,
        isstar: row['isstar'] == 1,
      ));
    }

    setState(() {
      data = tempData;
    });
  }

  Future<void> addTodo(String title, bool isComplated, bool isStar) async {
    final conn = await MySqlConnection.connect(connectionString);
    await conn.query(
        "INSERT INTO todo (title, iscomplated, isstar) VALUES ('$title', '${isComplated ? 1 : 0}', '${isStar ? 1 : 0}')");

    connectMysql();
  }

  Future<void> deleteTodo(int id) async {
    final conn = await MySqlConnection.connect(connectionString);
    await conn.query("DELETE FROM todo WHERE id = $id");
    connectMysql();
  }

  void updateIsCompleted(int id, bool isCompleted) async {
    final conn = await MySqlConnection.connect(connectionString);
    await conn.query(
        "UPDATE todo SET iscomplated = '${isCompleted ? 1 : 0}' WHERE id = $id");
    connectMysql();
  }

  Future<void> editTodoTitle(int id, String newTitle) async {
    final conn = await MySqlConnection.connect(connectionString);
    await conn.query("UPDATE todo SET title = '$newTitle' WHERE id = $id");
    connectMysql();
  }

  Future<void> editTodoStar(int id, bool isStar) async {
    final conn = await MySqlConnection.connect(connectionString);
    await conn
        .query("UPDATE todo SET isstar = '${isStar ? 1 : 0}' WHERE id = $id");
    connectMysql();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          var item = data[index];
          return Card(
            elevation: 4,
            shadowColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListTile(
              key: Key(item.id.toString()),
              leading: Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                value: item.iscomplated ? true : false,
                onChanged: (bool? isComplated) {
                  setState(() {
                    updateIsCompleted(item.id, isComplated!);
                  });
                },
              ),
              title: TextFormField(
                initialValue: item.title,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onFieldSubmitted: (value) {
                  setState(() {
                    editTodoTitle(item.id, value);
                  });
                },
              ),
              trailing: SizedBox(
                width: 60,
                child: Row(
                  children: [
                    InkWell(
                      child: item.isstar == true
                          ? const Icon(
                              Icons.star,
                              color: Colors.yellow,
                            )
                          : const Icon(Icons.star),
                      onTap: () {
                        setState(() {
                          editTodoStar(item.id, !item.isstar!);
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      child: const Icon(Icons.delete),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Emin misiniz?'),
                              content: const Text(
                                  'Silmek istediğinize emin misiniz?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('İptal'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Sil'),
                                  onPressed: () {
                                    deleteTodo(item.id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          addTodo("Yeni to-do", false, false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "To-do adını düzenlemek için üstüne tıklayabilirsiniz.",
                style: TextStyle(fontSize: 19),
              ),
            ),
          );
        },
      ),
    );
  }
}
