import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  Position? currentPosition;
  late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  late LatLng _initialPosition;
  late bool _loading;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();

    //位置情報が許可されていない時に許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
    });

    _loading = true;
    _getUserLocation();
  }



  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
      print(position);
    });
  }



  //現在位置を更新し続ける
  void positionstrem() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
          currentPosition = position;
          print(position == null
              ? 'Unknown'
              : '${position.latitude.toString()}, ${position.longitude
              .toString()}');
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? CircularProgressIndicator()
          : SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [

            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 17,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              onTap: (LatLng latLang) {
                print('Clicked: $latLang');
              },
              myLocationEnabled: true,

            ),
            //buildFloatingSearchBar(),
          ],
        ),
      ),
    );
  }



  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('toire').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data!.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      //children: snapshot.map((data) => _buildListMap(context, data)).toList(),
      //children: snapshot.map((data) => _buildListMap(context, data)).toList(),
    );
  }

//Widget build(BuildContext context, DocumentSnapshot data) {
// Widget _buildListMap(BuildContext context, DocumentSnapshot data) {
//   final record = Record.fromSnapshot(data);
//   //       );
// }
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
  // idokeido = map['idokeido'];
        name = map['name'],
        ido = map['ido'],
        keido = map['keido'];
  //idokeido = map['idokeido'];
  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$ido:$keido>";
}