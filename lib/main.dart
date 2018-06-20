import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'image_upload.dart';
import 'fullscreen_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(      
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> wallpapersList;
  final CollectionReference collectionReference = Firestore.instance.collection("Images");

  @override
  void initState() {
    super.initState();
    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        wallpapersList = datasnapshot.documents;
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter Image Database "),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add), onPressed: () {
             Navigator.push(context, new MaterialPageRoute(
                      builder: (context) => new ImageShare()));
          }),
        ],
      ),
      body: wallpapersList != null 
      ? new StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          padding: const EdgeInsets.all(8.0),
          itemCount: wallpapersList.length,
          itemBuilder: (context,i){
            String imgPath = wallpapersList[i].data['url'];
            return new Material(
              elevation: 8.0,
              borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
              child: new InkWell(
                onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new FullScreen(imgPath))),
                child: new Hero(
                    tag: imgPath,
                    child: new FadeInImage(
                        placeholder: new AssetImage("images/wallfy.png"),
                        image: new NetworkImage(imgPath),
                        fit: BoxFit.cover,
                    )
                ),
              ),
            );
          },
        staggeredTileBuilder: (i) => new StaggeredTile.count(2, i.isEven?2:3),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      )
      : new Center(
        child: new CircularProgressIndicator(),
      )
    );
  }
}