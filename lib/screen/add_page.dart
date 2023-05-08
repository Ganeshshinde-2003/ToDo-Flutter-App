import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({Key? key, required this.todo}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( !isEdit ? "Add ToDo" : "Edit ToDo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: "Title "
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: "Description",
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20,),
          ElevatedButton( 
              onPressed: isEdit ? updateData : submitData ,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isEdit ? "Update" : "Submit"),
              ))
        ],
      ),
    );
  }

  Future <void> updateData() async {
    // Get the data from the form
    final todo = widget.todo;
    if(todo == null){
      return;
    }
    final id = todo["_id"];
    final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title" : title,
      "description": description,
      "is_completed": isCompleted,
    };

    // Submit updated data to the server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);

    final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json"
        }
    );

    if(response.statusCode == 200){
      showSuccessMessage("Creation Success");
      Navigator.pop(context);
    }
    else{
      showSuccessMessage("Inundation Failed");
    }

  }

  Future<void> submitData() async {
    
    // Get the data from the form
    
    final title = titleController.text;
    final description = descriptionController.text;
    
    final body = {
      "title" : title,
      "description": description,
      "is_completed": false,
    };
    
    // Submit the data to the server
    const url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);

    final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json"
        }
    );

    // show success or fail message based on status

    if(response.statusCode == 201){
      titleController.text = "";
      descriptionController.text = "";
      showSuccessMessage("Creation Success");
      Navigator.pop(context);
    }
    else{
      showSuccessMessage("Creation Failed");
    }
  }

  void showSuccessMessage (message) {
    final snackBar = SnackBar(

      backgroundColor: message == "Creation Success" ? Colors.blue : Colors.red,
        content: Text(message, style: const TextStyle(color: Colors.white),));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
