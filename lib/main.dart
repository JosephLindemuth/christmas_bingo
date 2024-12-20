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

  @override
  void initState() {
    super.initState();
    _loadSquareStates();
    squareStates[12] = true;
  }

  Future<void> _loadSquareStates() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedStates = prefs.getStringList('squareStates');
    if (storedStates != null) {
      setState(() {
        squareStates = storedStates.map((state) => state == 'true').toList();
      });
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade100,
          title: Text(
            shortDescriptions[index].replaceAll('\n', ' '),
          ),
          content: Text(
            longDescriptions[index],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎄🌟 Christmas Bingo 🌟🎄'),
      ),
      body: Column(
        children: [
          // const Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Text(
          //       'BINGO',
          //       style: TextStyle(letterSpacing: 40, fontSize: 50),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      // Use Expanded to ensure GridView takes available space
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
                              _showDescriptionDialog(index);
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
                                    shortDescriptions[index],
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
                )),
          ),
        ],
      ),
    );
  }
}
