import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // return _buildList(context, dummySnapshot);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('toire').snapshots(), // babyは各々のコレクションIDに変更してください
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data!.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          subtitle: Text(record.ido.toString(),),
          trailing: Text(record.keido.toString(),),


          //onTap: () => record.reference.update({'votes': FieldValue.increment(1)}),
        ),
      ),
    );
  }
}

class Record {
  final String name;
  final double ido;
  final double keido;

  final DocumentReference reference;


  Record.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['name'] != null),
        assert(map['ido'] != null),
        assert(map['keido'] != null),
  //assert(map['idokeido'] != null),
        name = map['name'],
        ido = map['ido'],
        keido = map['keido'];
  // idokeido = map['idokeido'];
  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$ido:$keido>";
}