import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home(), debugShowCheckedModeBanner: false);
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Lists
  List<String> mainBreeds = [];
  List<String> subBreeds = [];
  List<String> results = [];

  // Selected options
  String? selectedBreed;
  String? selectedSubBreed;

  // Num Of Results
  int numOfResults = 5;
  // Current Num of Results which is updated after submit button is clicked
  int currentNumOfResults = 5;

  // Text Controller for Number of Results
  final TextEditingController numOfResultsController = TextEditingController(
    text: '5',
  );

  // Preferences
  late SharedPreferences myPrefs;

  // Preference Functions
  Future<void> initPrefs() async =>
      myPrefs = await SharedPreferences.getInstance();

  Future<void> saveNumOfResults() async =>
      await myPrefs.setInt("numOfResults", numOfResults);

  Future<void> loadNumOfResults() async => setState(() {
    numOfResultsController.text = myPrefs.getInt('numOfResults') != null
        ? myPrefs.getInt('numOfResults').toString()
        : '5';
    numOfResults = myPrefs.getInt('numOfResults') != null
        ? myPrefs.getInt('numOfResults')!
        : 5;
    currentNumOfResults = numOfResults;
  });

  // Get Breeds Function to populate dropdown
  Future<void> getBreeds(String fetchURL) async {
    // Get response and assign variables accordingly
    var response = await http.get(Uri.parse(fetchURL));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<dynamic> data = jsonResponse['message'];
        setState(() {
          mainBreeds = data.map((element) => element.toString()).toList();
        });
      }
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  // Get sub breeds function to populate subbreed dropdown
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
          selectedSubBreed = subBreeds.isNotEmpty ? subBreeds[0] : null;
        });
      }
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  // Get images and fill up image url array
  Future<void> getImages() async {
    // If no breed selected show error dialog to user
    if (selectedBreed == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Breed Selected"),
            content: Text(
              "You need to select at least one breed to search for.",
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Set appropriate fetch url
    String fetchURL = selectedSubBreed != null
        ? "https://dog.ceo/api/breed/$selectedBreed/$selectedSubBreed/images/random/$numOfResults"
        : "https://dog.ceo/api/breed/$selectedBreed/images/random/$numOfResults";

    var response = await http.get(Uri.parse(fetchURL));

    // If good response fill up results list
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
        // Save prefs of num of results
        await saveNumOfResults();
      }
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  // Validate search function for results text field
  // If field is empty or has letters and not numbers throw an error
  String? validateSearch(String value) {
    if (value.isEmpty) return 'Field cannot be empty';
    if (value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Field needs to be a number';
    }
    return null;
  }

  // Async init function
  // Loads breed types
  // Inits prefs
  // Load num of results if saved
  Future<void> initFunc() async {
    await getBreeds("https://dog.ceo/api/breeds/list");
    await initPrefs();
    await loadNumOfResults();
  }

  @override
  void initState() {
    super.initState();
    initFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Project 2 Dog API"),
        actions: [
          // Documentation Button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Project Information"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(onPressed: () => launchUrl(Uri.parse('https://dog.ceo/dog-api/')), child: Text("Dog API")),
                        Text(
                          "I went ahead and focused on getting API calls working correctly then focused on getting the grid working with the UI elements. After this I finally focused on polishing the app a bit.",
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.info),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // Row containing breed and sub breed dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedBreed,
                  hint: Text("Breed"),
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
                    selectedBreed = newValue!;
                    getSubBreeds();
                  },
                ),

                DropdownButton<String>(
                  value: selectedSubBreed,
                  hint: Text("SubBreed"),
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
              ],
            ),

            // Number of results field
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: numOfResultsController,
                      decoration: InputDecoration(
                        label: Text('Number of Results'),
                        errorText: validateSearch(
                          numOfResultsController.value.text,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.black),
                        ),
                      ),
                      onChanged: (value) => setState(() {
                        numOfResults = int.parse(value) <= 50
                            ? int.parse(value)
                            : 50;
                      }),
                    ),
                  ),
                ),
              ],
            ),

            // Submit Button
            TextButton(onPressed: () => getImages(), child: Text("Submit")),

            // Grid of images
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                ),
                itemCount: currentNumOfResults,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: results.isNotEmpty
                        ? results[index]
                        : 'https://placehold.co/400.png',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
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
