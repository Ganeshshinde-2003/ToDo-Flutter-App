import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_rest_api/screen/add_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchToDo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDo List"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchToDo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(child: Text("No ToDo Item", style: Theme.of(context).textTheme.headline3,),),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
                itemBuilder: (context, index){
                final item = items[index];
                final id = item["_id"];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child:Text("${index + 1}")),
                  title: Text(item['title'].toString()),
                  subtitle: Text(item["description"]),
                  trailing: PopupMenuButton(
                    onSelected: (value){
                      if(value == "edit"){
                        navigateToEditPage(context,item);
                      }
                      else if ( value == 'delete'){
                        deleteById(id);
                      }
                      else{}
                    },
                    itemBuilder: (context){
                      return[
                      const PopupMenuItem(child: Text("Edit"),
                      value: "edit",
                      ),
                        const PopupMenuItem(child: Text("Delete"),
                        value: "delete",
                        )
                      ];
                    },
                  ),
                ),
              );
            }),
          ),
        ),
        child: const Center(child: CircularProgressIndicator(),),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigateToAddPage(context), // Pass the context here
        label: const Text("Add ToDo"),
      ),
    );
  }

  Future<void> navigateToEditPage(BuildContext context, Map item) async { // Accept the BuildContext parameter
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTodoPage(todo: item)),
    );
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  Future<void> navigateToAddPage(BuildContext context) async { // Accept the BuildContext parameter
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoPage(todo: null,)),
    );
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  Future<void>deleteById(String id) async {

    // Delete the item
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);

    final response = await http.delete(uri);
    if(response.statusCode == 200) {
      // Remove the item from the list
      final filteredItems= items.where((element) => element["_id"] != id).toList();
      setState(() {
        items = filteredItems;
      });
    }else {
      showSuccessMessage("Unable to Delete");
    }
  }

  Future<void> fetchToDo () async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if( response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = json["items"] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
  void showSuccessMessage (message) {
    final snackBar = SnackBar(

        backgroundColor: message == "Creation Success" ? Colors.blue : Colors.red,
        content: Text(message, style: const TextStyle(color: Colors.white),));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
