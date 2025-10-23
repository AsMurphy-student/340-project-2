import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  String selectedBreed = '';
  String selectedSubBreed = 'N/A';

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

  Future<void> getImages(bool start) async {
    // Set appropriate fetch url
    // String fetchURL =
    // "https://api.giphy.com/v1/gifs/search"
    // "?q=${searchFieldController.value.text}"
    // "&limit=$dropdownValue"
    // "&api_key=oDfbe1wIxGVqJFOs6LRpjp4cPKXeMh8Y";

    // Get response and assign variables accordingly
    // var response = await http.get(Uri.parse(fetchURL));

    // if (response.statusCode == 200) {
    //   var jsonResponse = jsonDecode(response.body);
    //   data = jsonResponse['data'];

    //   // setState(() {

    //   // });
    // } else {
    //   print("Theres a problem: ${response.statusCode}");
    // }
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
                    print(newValue);
                  },
                ),

                DropdownButton<String>(
                  value: selectedSubBreed,
                  // hint: Text("Rating (allows set rating and below)"),
                  icon: const Icon(Icons.arrow_downward),
                  items: subBreeds.isNotEmpty
                      ? subBreeds.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
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
                    // setState(() {
                    //   rating = newValue!;
                    // });
                    print(newValue);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
