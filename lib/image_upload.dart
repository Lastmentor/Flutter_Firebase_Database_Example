import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';

class ImageShare extends StatefulWidget {
  @override
  _ImageShareState createState() => new _ImageShareState();
}

class _ImageShareState extends State<ImageShare> {

  final DocumentReference documentReference = Firestore.instance.collection('Images').document();

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          leading: new IconButton(
              icon: new Icon(
                  Icons.arrow_back_ios
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }
          ),
          title: new Text('Upload Image'),
          centerTitle: true,
        ),
        body: new ListView(
          padding: new EdgeInsets.all(32.0),
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Padding(padding: const EdgeInsets.only(top: 20.0)),
                new Center(
                  child: _image == null
                      ? new Text('Image Not Selected')
                      : new Image.file(_image),
                ),
                new Padding(padding: const EdgeInsets.only(top: 20.0)),
                new MaterialButton(
                      onPressed: getImage,
                      height: 40.0,
                      minWidth: 140.0,
                      color: Colors.green,
                      textColor: Colors.white,
                      child: new Text("Select an Image"),
                      splashColor: Colors.redAccent,
                    ),
              ],
            )
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _addData,
          tooltip: 'Share Post',
          child: new Icon(Icons.send),
        ),
      ),
    );
  }

  void _addData() async {
    if(_image == null){
      _alertDialog();
    }else{
      final String rand1 = "${new Random().nextInt(10000)}";
      final String rand2 = "${new Random().nextInt(10000)}";
      final String rand3 = "${new Random().nextInt(10000)}";
      final StorageReference ref = FirebaseStorage.instance.ref().child('${rand1}_${rand2}_${rand3}.jpg');
      final StorageUploadTask uploadTask = ref.put(_image);
      final Uri downloadUrl = (await uploadTask.future).downloadUrl;
      documentReference.setData({'url':downloadUrl.toString()});
      setState(() {
            _image = null;
      });
    }    
  }

  void _alertDialog(){
    AlertDialog dialog = new AlertDialog(
      content: new Text("Select an Image",textAlign: TextAlign.center,),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.of(context).pop(), child: new Text("OK")),
      ],
    );
    showDialog(context: context, child: dialog);
  }
}