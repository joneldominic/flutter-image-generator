import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ImageGenerator(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageGenerator extends StatefulWidget {
  @override
  _ImageGeneratorState createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  final canvasWidth = 1013.0;
  final canvasHeight = 638.0;
  ByteData imgBytes;
  bool isImageloaded = false;

  final directoryName = 'flutter';

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/template/front.png'),
          imgBytes != null
              ? Center(
                  child: Image.memory(
                    Uint8List.view(imgBytes.buffer),
                  ),
                )
              : Center(
                  child: Image.asset('assets/template/back.png'),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: RaisedButton(
                  child: Text('Generate ID'),
                  onPressed: () => generateImage(
                    profilePath: 'assets/data/profile.jpg',
                    qrPath: 'assets/data/qr.png',
                    name: 'Jonel Dominic Tapang'.toUpperCase(),
                    code: 'JDT1234',
                    address: 'Barangay, City, Province',
                    number: '09123456789',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: RaisedButton(
                  child: Text('Clear ID'),
                  onPressed: imgBytes != null
                      ? () {
                          setState(() {
                            imgBytes = null;
                          });
                        }
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: RaisedButton(
                  child: Text('Save ID'),
                  onPressed: imgBytes != null ? () => saveImage('JDT1234') : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<ByteData> generateProfileImage(String profilePath) async {
    final profileSize = 274.0;

    final ByteData profile = await rootBundle.load(profilePath);
    ui.Image profileImage = await loadImage(Uint8List.view(profile.buffer));

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(Offset(0.0, 0.0), Offset(profileSize, profileSize)),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, profileSize, profileSize),
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.fill
        ..strokeWidth = 7,
    );

    if (isImageloaded) {
      canvas.drawImageRect(
        profileImage,
        Rect.fromCenter(
          center: Offset(profileImage.width / 2, profileImage.height / 2),
          width: (profileImage.height > profileImage.width
                  ? profileImage.height
                  : profileImage.width)
              .toDouble(),
          height: (profileImage.height > profileImage.width
                  ? profileImage.height
                  : profileImage.width)
              .toDouble(),
        ),
        Rect.fromLTWH(0, 0, profileSize, profileSize),
        Paint(),
      );
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(profileSize.toInt(), profileSize.toInt());
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);

    return pngBytes;
  }

  void generateImage({
    @required String profilePath,
    @required String qrPath,
    @required String name,
    @required String code,
    @required String address,
    @required String number,
  }) async {
    final ByteData data = await rootBundle.load('assets/template/back.png');
    ui.Image templateImage = await loadImage(Uint8List.view(data.buffer));

    ui.Image profileImage = await loadImage(
        Uint8List.view((await generateProfileImage(profilePath)).buffer));

    final ByteData qrData = await rootBundle.load(qrPath);
    ui.Image qrImage = await loadImage(Uint8List.view(qrData.buffer));

    final recorder = ui.PictureRecorder();

    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset(0.0, 0.0),
        Offset(canvasWidth, canvasHeight),
      ),
    );

    if (isImageloaded) {
      canvas.drawImage(profileImage, Offset(228.0, 183.0), Paint());
      canvas.drawImage(templateImage, Offset(0.0, 0.0), Paint());
      canvas.drawImageRect(
        qrImage,
        Rect.fromLTWH(
            0, 0, qrImage.width.toDouble(), qrImage.height.toDouble()),
        Rect.fromLTWH(687, 407, 200, 200),
        Paint(),
      );
    }

    final labelXOffset = 605.0;
    TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: 30,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: 413,
      )
      ..paint(
        canvas,
        Offset(
          labelXOffset,
          115,
        ),
      );

    TextPainter(
      text: TextSpan(
        text: code,
        style: TextStyle(
          fontSize: 30,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: 300,
      )
      ..paint(
        canvas,
        Offset(
          labelXOffset,
          200,
        ),
      );

    TextPainter(
      text: TextSpan(
        text: address,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: 300,
      )
      ..paint(
        canvas,
        Offset(
          labelXOffset,
          290,
        ),
      );

    TextPainter(
      text: TextSpan(
        text: number,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: 300,
      )
      ..paint(
        canvas,
        Offset(
          labelXOffset,
          325,
        ),
      );

    final picture = recorder.endRecording();
    final img =
        await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);

    setState(() {
      imgBytes = pngBytes;
    });
  }

  void saveImage(String userCode) async {
    if (!(await Permission.storage .request().isGranted)) await Permission.storage.request();

    Directory directory = await getExternalStorageDirectory();
    String path = directory.path;
    print(path);
    await Directory('$path/$directoryName').create(recursive: true);
    File('$path/$directoryName/$userCode.png')
        .writeAsBytesSync(imgBytes.buffer.asInt8List());

    print("Saved Succuessfully");
  }
}
