import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // late List<dynamic> data;
  List<String> mainBreeds = [];
  List<String> subBreeds = [];
  List<String> results = [];

  String selectedBreed = '';
  String selectedSubBreed = 'N/A';

  int numOfResults = 5;
  int currentNumOfResults = 5;

  final TextEditingController numOfResultsController = TextEditingController(
    text: '5',
  );

  Future<void> getBreeds(String fetchURL) async {
    // Get response and assign variables accordingly
    var response = await http.get(Uri.parse(fetchURL));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<dynamic> data = jsonResponse['message'];
        setState(() {
          mainBreeds = data.map((element) => element.toString()).toList();
          selectedBreed = mainBreeds[0];
        });
      }
      // data = jsonResponse['data'];
      // print(jsonResponse['message']);
      // List<dynamic> data = jsonResponse['message'].map(
      //   (element) => {print(element)},
      // );
      // List<dynamic> data = jsonResponse['message'];
      // print(data);

      // setState(() {

      // });
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  Future<void> getSubBreeds() async {
    // Get response and assign variables accordingly
    var response = await http.get(
      Uri.parse("https://dog.ceo/api/breed/$selectedBreed/list"),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<dynamic> data = jsonResponse['message'];
        setState(() {
          subBreeds = data.isNotEmpty
              ? data.map((element) => element.toString()).toList()
              : [];
          selectedSubBreed = subBreeds.isNotEmpty ? subBreeds[0] : 'N/A';
        });
      }
      // data = jsonResponse['data'];
      // print(jsonResponse['message']);
      // List<dynamic> data = jsonResponse['message'].map(
      //   (element) => {print(element)},
      // );
      // List<dynamic> data = jsonResponse['message'];
      // print(data);

      // setState(() {

      // });
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  Future<void> getImages() async {
    // Set appropriate fetch url
    String fetchURL = selectedSubBreed != 'N/A'
        ? "https://dog.ceo/api/breed/$selectedBreed/$selectedSubBreed/images/random/$numOfResults"
        : "https://dog.ceo/api/breed/$selectedBreed/images/random/$numOfResults";

    var response = await http.get(Uri.parse(fetchURL));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<dynamic> data = jsonResponse['message'];
        setState(() {
          results = data.map((element) => element.toString()).toList();
          if (results.length <= numOfResults) {
            numOfResults = results.length;
            numOfResultsController.text = results.length.toString();
          }
          currentNumOfResults = numOfResults;
        });
        // setState(() {
        //   results = data
        //       .map((element) => {element.toString()})
        //       .cast<String>()
        //       .toList();
        // });
        // print(results);
      }
      // data = jsonResponse['data'];
      // print(jsonResponse['message']);
      // List<dynamic> data = jsonResponse['message'].map(
      //   (element) => {print(element)},
      // );
      // List<dynamic> data = jsonResponse['message'];
      // print(data);

      // setState(() {

      // });
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  String? validateSearch(String value) {
    if (value.isEmpty) return 'Field cannot be empty';
    if (value.contains(RegExp(r'[a-zA-Z]')))
      return 'Field needs to be a number';
    return null;
  }

  Future<void> initFunc() async {
    await getBreeds("https://dog.ceo/api/breeds/list");
  }

  @override
  void initState() {
    super.initState();
    initFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedBreed,
                  // hint: Text("Rating (allows set rating and below)"),
                  icon: const Icon(Icons.arrow_downward),
                  items: mainBreeds.isNotEmpty
                      ? mainBreeds.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : [''].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    // setState(() {
                    //   rating = newValue!;
                    // });
                    // print(newValue);
                    selectedBreed = newValue!;
                    getSubBreeds();
                  },
                ),

                DropdownButton<String>(
                  value: selectedSubBreed,
                  // hint: Text("Rating (allows set rating and below)"),
                  icon: const Icon(Icons.arrow_downward),
                  items: subBreeds.isNotEmpty
                      ? subBreeds.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : ['N/A'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubBreed = newValue!;
                    });
                  },
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: numOfResultsController,
                    decoration: InputDecoration(
                      label: Text('Search Term'),
                      errorText: validateSearch(
                        numOfResultsController.value.text,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.black),
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      numOfResults = int.parse(value);
                    }),
                  ),
                ),
                TextButton(onPressed: () => getImages(), child: Text("Submit")),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                ),
                itemCount: currentNumOfResults,
                itemBuilder: (context, index) {
                  return Image.network(
                    results.isNotEmpty
                        ? results[index]
                        : 'https://placehold.co/400.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
