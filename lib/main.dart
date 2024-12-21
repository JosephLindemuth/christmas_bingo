import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const BingoApp());
}

class BingoApp extends StatelessWidget {
  const BingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Christmas Bingo', // Updated title with emojis
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.red.shade100,
        textTheme: ThemeData.light().textTheme.copyWith(
            // Dialog headline
            headlineSmall: TextStyle(
                // Custom text style for app bar title
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900]),
            bodyMedium: TextStyle(
              fontSize: 18,
              color: Colors.grey[900],
            ),
            headlineMedium: const TextStyle(color: Colors.red)),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            foregroundColor: Colors.red[600], // Text color in normal state
          ),
        ),
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
              backgroundColor: Colors.green,
              toolbarHeight: 70,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      home: const BingoScreen(),
    );
  }
}

class BingoScreen extends StatefulWidget {
  const BingoScreen({super.key});

  @override
  BingoScreenState createState() => BingoScreenState();
}

class BingoScreenState extends State<BingoScreen> {
  static const List<String> shortDescriptions = [
    'Sexist\ngifts',
    'Return\ngift',
    'Twin\nmix up',
    'Gregg\nbody\ncomments',
    'Sheffield\nwomen\nargument',
    'Grandma\nGlenn\nstress',
    'Caleb\npooping',
    'Aimee\nkeeps\nLeni up',
    'Tiny\napple\npie',
    '500\nWPM',
    'Sketchy',
    'Turnpikes',
    'Free\nSpace!',
    'Grandma\'s\nspite',
    'Duplicate\nboard\ngame',
    'Christmas\nlights',
    'Christmas\nEve\nservice',
    'Trash\nattack',
    'Crying',
    'Complaints\nabout\nGregg',
    'Secret\nroom',
    'Karen\nhides from\nphoto',
    'Jackbox\ngames',
    'Mima\ndementia',
    'Critical\nmass'
  ];

  static const List<String> longDescriptions = [
    'Grandma gives boys and girls different gifts.',
    'Grandma tells Leni she can return her gift.',
    'Dad mixes up the twins.',
    'Gregg makes innappropriate comments about people\'s bodies.',
    'The Sheffield women get in an argument.',
    'Grandma stresses about Glenn.',
    'We have to wait for Caleb to poop at an inconvenient time.',
    'Aimee yapping keeps Leni up.',
    'Grandma makes a tiny apple pie for everyone.',
    'Benjamin, Katerina, and Colleen talk at 500 words per minute.',
    'Aimee and Wyatt are "Sketchy".',
    'Karen rants about turnpikes..',
    'Free space!',
    'Grandma spites a woman in a game.',
    'Somebody receives a duplicate of a board game.',
    'We see the Christmas lights at Mom\' request.',
    'We attend the Christmas eve service.',
    'Dad throws trash and hits someone.',
    'Crying due to miscommunication.',
    'Karen complains about Gregg spending too much money, being lazy, sleeping all the time, or his hobbies.',
    'We find a secret room in the AirBnB.',
    'Karen hides from a photo being taken.',
    'We play Jackbox games.',
    'Mima tells the same story 3 or more times.',
    'We achieve critical mass.'
  ];

  List<bool> squareStates = List<bool>.filled(25, false);
  late Map<int, int>? randomMapping = null;

  @override
  void initState() {
    super.initState();
    _loadSquareStates();
    squareStates[12] = true;
  }

  Future<void> _loadSquareStates() async {
    final prefs = await SharedPreferences.getInstance();

    // Load square pressed states
    List<String>? storedStates = prefs.getStringList('squareStates');
    if (storedStates != null) {
      setState(() {
        squareStates = storedStates.map((state) => state == 'true').toList();
      });
    }

    // Load mapping for randomizing squares
    // Retrieve the map
    Map<int, int>? retrievedMapping = await retrieveMapFromPreferences();
    if (retrievedMapping != null) {
      setState(() {
        randomMapping = retrievedMapping;
      });
    } else {
      setState(() {
        randomMapping = generateUniqueMapping();
      });

      await storeMapInPreferences(randomMapping!);
    }
  }

  Future<void> _saveSquareStates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'squareStates',
      squareStates.map((state) => state.toString()).toList(),
    );
  }

  void _toggleSquare(int index) {
    Vibration.vibrate(duration: 5);
    setState(() {
      squareStates[index] = !squareStates[index];
    });
    _saveSquareStates();
  }

  void _showDescriptionDialog(int index) {
    if (randomMapping != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red.shade100,
            title: Text(
              shortDescriptions[randomMapping![index]!].replaceAll('\n', ' '),
            ),
            content: Text(
              longDescriptions[randomMapping![index]!],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎄🌟 Christmas Bingo 🌟🎄'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        bool isActive = squareStates[index];
                        return GestureDetector(
                          onTap: () => _toggleSquare(index),
                          onLongPress: () {
                            Vibration.vibrate(duration: 20);
                            randomMapping != null
                                ? _showDescriptionDialog(index)
                                : null;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  randomMapping != null
                                      ? shortDescriptions[
                                          randomMapping![index]!]
                                      : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Bingos:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_calculateBingos(squareStates)}',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: const Text(
              'Long press a square for full description',
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

/// Function to calculate the number of bingos
int _calculateBingos(List<bool> squareStates) {
  // Define bingo patterns: rows, columns, diagonals
  const List<List<int>> bingoPatterns = [
    // Rows
    [0, 1, 2, 3, 4],
    [5, 6, 7, 8, 9],
    [10, 11, 12, 13, 14],
    [15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24],
    // Columns
    [0, 5, 10, 15, 20],
    [1, 6, 11, 16, 21],
    [2, 7, 12, 17, 22],
    [3, 8, 13, 18, 23],
    [4, 9, 14, 19, 24],
    // Diagonals
    [0, 6, 12, 18, 24],
    [4, 8, 12, 16, 20],
  ];

  int bingos = 0;

  for (var pattern in bingoPatterns) {
    if (pattern.every((index) => squareStates[index])) {
      bingos++;
    }
  }

  return bingos;
}

// Generate a random map
Map<int, int> generateUniqueMapping() {
  List<int> availableNumbers = List.generate(25, (index) => index);
  Map<int, int> mapping = {};

  mapping[12] = 12; // Fixed mapping
  availableNumbers.remove(12);

  final random = Random();
  for (int i = 0; i < 25; i++) {
    if (i == 12) continue;

    int randomIndex = random.nextInt(availableNumbers.length);
    mapping[i] = availableNumbers[randomIndex];
    availableNumbers.removeAt(randomIndex);
  }

  return mapping;
}

// Store the map in SharedPreferences
Future<void> storeMapInPreferences(Map<int, int> mapping) async {
  final prefs = await SharedPreferences.getInstance();
  // Convert keys to strings for JSON compatibility
  String jsonString =
      jsonEncode(mapping.map((key, value) => MapEntry(key.toString(), value)));
  await prefs.setString('randomMapping', jsonString);
}

// Retrieve the map from SharedPreferences
Future<Map<int, int>?> retrieveMapFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs.getString('randomMapping');
  if (jsonString == null) return null;

  // Decode JSON and convert keys back to integers
  Map<String, dynamic> stringKeyMap = jsonDecode(jsonString);
  return stringKeyMap.map((key, value) => MapEntry(int.parse(key), value));
}
