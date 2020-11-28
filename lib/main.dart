import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
void main() {
  runApp(MaterialApp(
    home: Finder(),
  ));
}

class Finder extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Finder> {
  File pickedImage;
  bool imgPicked = false; //while the app starts for the first time it will expect t6he image as we have not provided the image initially the app will crash hence we create a bool and use ternary operator in the future
  String ocr_text = '';
  bool isClicked = false; //to show card only after clicking the button

  //list of harmful ingredients in food
  List nI = ['Sodium nitrate','Sulfites','Azodicarbonamide','Potassium bromate',
    'Propyl gallate','BHT','BHA','Propylene glycol','Butane','Monosodium glutamate','MSG',
    'Disodium inosinate','Disodium guanylate','Enriched flour','Recombinant Bovine Growth Hormone',
    'Refined vegetable oil','Sodium benzoate','Brominated vegetable oil',
    'Propyl gallate','Olestra','Carrageenan','Polysorbate 60','Camauba wax',
    'Magnesium sulphate','Chlorine dioxide','Paraben','Sodium carboxymethyl cellulose',
    'Aluminum','Saccharin','Aspartame','High fructose corn syrup','Acesulfame potassium',
    'Sucralose','Agave nectar','Bleached starch','Tert butylhydroquinone','Red #40','Blue #1',
    'Blue #2','Citrus red #1','Citrus red #2','Green #3','Yellow #5','Yellow #6','Red #2','Red #3',
    'Caramel coloring','Brown HT','Orange B','Bixin','Norbixin','Annatto'];
  List bI = [];
  //to open gallery and select image for finding
  Future pickImage() async {
    var galleryimg = await ImagePicker.pickImage(source: ImageSource.gallery);//we select from gallery and store the image in variable galleryimg

    setState(() {
      if (galleryimg != null)
        {
          pickedImage = galleryimg;
          imgPicked = true; //as we have selected the image now we can change it to true and we can show the image
          isClicked = false;
        }
      else
        {
          imgPicked = false;
        }

    });
  }

  //to open camera and take image for finding
  Future openCamera() async {
    var cameraimg = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (cameraimg != null)
        {
          pickedImage = cameraimg;
          imgPicked = true;
          isClicked = false;
        }
      else
        {
          imgPicked = false;
        }

    });
  }


  //the function that does ocr
  Future readText() async {
    FirebaseVisionImage image = FirebaseVisionImage.fromFile(pickedImage); //create an instance to load our image
    TextRecognizer text = FirebaseVision.instance.textRecognizer(); //create a text recognize instance
    VisionText readText = await text.processImage(image); //use the above instance to find text in our firebase image
    /*for (TextBlock block in readText.blocks) {
      ocr_text = ocr_text + block.text;
    }*/
    for (TextBlock block in readText.blocks) {
      //print(block.text); //get sentence/s
      for (TextLine line in block.lines) {
        print(line.text); //get lines
        if (nI.contains(line.text))
          {
            bI.add(line.text);
          }
        for (TextElement word in line.elements) {
          print(word.text);

        }
      }
    }


    //print(ocr_text);
    setState(() {
      if (bI.length == 0)
      {
        ocr_text = 'No harmful ingredient found';
      }
      else
      {
        String add = 'is present and harmful';
        ocr_text = bI.join()+ add;
      }
    });
    //print(ocr_text);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(
          'Secure food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[600],
        child: Text(
            'Read',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15
          ),
        ),
        onPressed: () {
          readText();
          setState(() {
            isClicked = true;
            ocr_text = '';
            bI.clear();
          });
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: imgPicked ? Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(pickedImage), fit: BoxFit.cover)
                  )
                ) : Container(
                child: Column(
                  children: [
                    Icon(
                      Icons.file_upload,
                      size: 200,
                      color: Colors.black,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Upload Image',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                      ),
                    ),
                  ],
                ),
              )
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: RaisedButton(
                  color: Colors.black,
                  onPressed: () {
                    pickImage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Open gallery',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 25,
                      ),
                    ),
                  ),
                )
                ),
                SizedBox(width: 20),
                Center(child: RaisedButton(
                  color: Colors.black,
                  onPressed: () {
                    openCamera();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Open camera',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 25,
                      ),
                    ),
                  ),
                )
                ),
              ],
            ),
            SizedBox(height: 30),
            isClicked ? Card(
              margin: EdgeInsets.all(10),
              elevation: 20,
              color: Colors.black,
              shadowColor: Colors.yellowAccent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ocr_text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.yellow,
                        letterSpacing: 3,
                        wordSpacing: 5
                      ),
                    ),
                  ],
                ),
              ),
            ) : Container(),
            isClicked ? Card(
              margin: EdgeInsets.all(10),
              elevation: 20,
              color: Colors.white,
              shadowColor:Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Detected ingredients',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.amber[800],
                        letterSpacing: 1.5
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      bI.join(),
                    )
                  ],
                ),
              ),
            ): Container(),
          ],

        ),
      ),
    );
  }


}