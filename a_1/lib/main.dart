import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VangtiChai',
      debugShowCheckedModeBanner: false,
      home: const VangtiPage(),
    );
  }
}

class VangtiPage extends StatefulWidget {
  const VangtiPage({super.key});

  @override
  State<VangtiPage> createState() => _VangtiPageState();
}

class _VangtiPageState extends State<VangtiPage> {
  String input = '';
  List<int> takaNotes = [500, 100, 50, 20, 10, 5, 2, 1];

  int get total {
    if (input == '') {
      return 0;
    }
    return int.parse(input);
  }

  Map<int, int> getChange() {
    int money = total;
    Map<int, int> ans = {};

    for (int note in takaNotes) {
      ans[note] = money ~/ note;
      money = money % note;
    }

    return ans;
  }

  void pressNumber(String n) {
    setState(() {

      if (input.isEmpty && n == '0') {
        return;
      }

      if (input.length < 8) {
        input = input + n;
      }
    });
  }

  void clear() {
    setState(() {
      input = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context);
    bool isPortrait = screen.orientation == Orientation.portrait;
    bool isTablet = screen.size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VangtiChai',
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.teal,
        toolbarHeight: 45,
      ),
      body: SafeArea(
        child: isPortrait
            ? portraitDesign(isTablet)
            : landscapeDesign(isTablet),
      ),
    );
  }

  Widget portraitDesign(bool tablet) {
    double leftRight = tablet ? 150 : 30;
    double topGap = tablet ? 45 : 25;

    return Padding(
      padding: EdgeInsets.only(
        left: leftRight,
        right: leftRight,
        top: topGap,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              input == '' ? 'Taka:' : 'Taka: $input',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: tablet ? 45 : 30),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: noteList()),
                keypad(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget landscapeDesign(bool tablet) {
    double leftRight = tablet ? 120 : 50;
    double topGap = tablet ? 25 : 15;

    return Padding(
      padding: EdgeInsets.only(
        left: leftRight,
        right: leftRight,
        top: topGap,
      ),
      child: Column(
        children: [
          Text(
            input == '' ? 'Taka:' : 'Taka: $input',
            style: const TextStyle(fontSize: 18),
          ),
          SizedBox(height: tablet ? 35 : 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: noteListForLandscape()),
                const SizedBox(width: 20),
                keypad(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget noteList() {
    Map<int, int> change = getChange();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: takaNotes.map((note) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            '$note: ${change[note]}',
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget noteListForLandscape() {
    Map<int, int> change = getChange();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              noteText(500, change[500]),
              noteText(100, change[100]),
              noteText(50, change[50]),
              noteText(20, change[20]),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              noteText(10, change[10]),
              noteText(5, change[5]),
              noteText(2, change[2]),
              noteText(1, change[1]),
            ],
          ),
        ),
      ],
    );
  }

  Widget noteText(int note, int? count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        '$note: $count',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget keypad(bool landscape) {
    List<List<String>> buttons;

    if (landscape) {
      buttons = [
        ['1', '2', '3', '4'],
        ['5', '6', '7', '8'],
        ['9', '0', 'CLEAR'],
      ];
    } else {
      buttons = [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
        ['0', 'CLEAR'],
      ];
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((b) {
            bool clearButton = b == 'CLEAR';

            return Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                width: clearButton ? 78 : 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: clearButton
                      ? clear
                      : () {
                    pressNumber(b);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    b,
                    style: TextStyle(
                      fontSize: clearButton ? 13 : 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
