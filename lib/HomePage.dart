import 'package:flutter/material.dart';
import 'package:todo_app/database_helper.dart';
import 'package:todo_app/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final allRows = await _databaseHelper.queryAll();
    final todos = allRows.map((row) => Todo.fromMap(row)).toList();

    setState(() {
      _todos = todos;
    });
  }

  void _showTodoDialog({Todo? todo}) {
    final isNewTodo = todo == null;
    final titleController = TextEditingController(text: isNewTodo ? '' : todo!.title);
    final descriptionController = TextEditingController(text: isNewTodo ? '' : todo!.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isNewTodo ? 'Add Todo' : 'Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (isNewTodo) {
                  final newTodo = Todo(
                    title: titleController.text,
                    description: descriptionController.text,
                  );
                  await _databaseHelper.insert(newTodo.toMap());
                } else {
                  final updatedTodo = Todo(
                    id: todo!.id,
                    title: titleController.text,
                    description: descriptionController.text,
                  );
                  await _databaseHelper.update(updatedTodo.toMap());
                }
                _fetchTodos();
                Navigator.of(context).pop();
              },
              child: Text(isNewTodo ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(int id) async {
    await _databaseHelper.delete(id);
    _fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Center(child: Text('TODO LIST')),
      ),
      body: ListView.builder(
        
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            
            title: Text(todo.title),
            subtitle: Text(todo.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showTodoDialog(todo: todo),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTodo(todo.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(),
        child: Icon(Icons.add),
      ),
    );

    
  }
}