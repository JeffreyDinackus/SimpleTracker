import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TrackerApp());
}

class TrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrackerHomePage(),
    );
  }
}

class TrackerHomePage extends StatefulWidget {
  @override
  _TrackerHomePageState createState() => _TrackerHomePageState();
}

class _TrackerHomePageState extends State<TrackerHomePage> {
  List<Tracker> trackers = [];

  @override
  void initState() {
    super.initState();
    _loadTrackers();
  }

  Future<void> _loadTrackers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? trackerList = prefs.getStringList('trackers');

    if (trackerList != null) {
      List<Tracker> loadedTrackers = trackerList.map((trackerString) {
        List<String> parts = trackerString.split(':');
        String label = parts[0];
        int count = int.parse(parts[1]);
        return Tracker(label: label, count: count);
      }).toList();

      setState(() {
        trackers = loadedTrackers;
      });
    }
  }

  Future<void> _saveTrackers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trackerList =
        trackers.map((tracker) => '${tracker.label}:${tracker.count}').toList();
    await prefs.setStringList('trackers', trackerList);
  }

  void _addTracker() {
    setState(() {
      trackers = List.from(trackers)..add(Tracker());
    });
    _saveTrackers();
  }

  void _removeTracker(int index) {
    setState(() {
      trackers = List.from(trackers)..removeAt(index);
    });
    _saveTrackers();
  }

  void _incrementCount(int index) {
    setState(() {
      trackers = List.from(trackers)..[index].count += 1;
    });
    _saveTrackers();
  }

  void _decrementCount(int index) {
    setState(() {
      trackers = List.from(trackers)..[index].count -= 1;
    });
    _saveTrackers();
  }

  void _updateTrackerLabel(int index, String label) {
    setState(() {
      trackers[index].label = label;
    });
    _saveTrackers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracker'),
      ),
      body: ListView.builder(
        itemCount: trackers.length,
        itemBuilder: (context, index) {
          return TrackerCard(
            tracker: trackers[index],
            onRemove: () => _removeTracker(index),
            onIncrement: () => _incrementCount(index),
            onDecrement: () => _decrementCount(index),
            onUpdateLabel: (label) => _updateTrackerLabel(index, label),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTracker,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Tracker {
  String label;
  int count;

  Tracker({this.label = 'Count', this.count = 0});
}

class TrackerCard extends StatefulWidget {
  final Tracker tracker;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onUpdateLabel;

  TrackerCard({
    required this.tracker,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onUpdateLabel,
  });

  @override
  _TrackerCardState createState() => _TrackerCardState();
}

class _TrackerCardState extends State<TrackerCard> {
  TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _labelController.text = widget.tracker.label;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _saveLabel() {
    widget.onUpdateLabel(_labelController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: 'Label',
                    ),
                    onChanged: (value) => _saveLabel(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Count: ${widget.tracker.count}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.onDecrement,
                  child: Icon(Icons.remove),
                ),
                ElevatedButton(
                  onPressed: widget.onIncrement,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
