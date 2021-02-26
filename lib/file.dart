import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class File extends StatefulWidget {
  @override
  _FileState createState() => _FileState();
}

class _FileState extends State<File> {
  @override
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType;

  void _openFileExplorer() async {
    setState(() => isLoadingPath = true);
    try {
      if (isMultiPick) {
        path = null;
        paths = await FilePicker.getMultiFilePath(
            type: fileType != null ? fileType : FileType.any,
            allowedExtensions: extensions);
      } else {
        path = await FilePicker.getFilePath(
            type: fileType != null ? fileType : FileType.any,
            allowedExtensions: extensions);
        paths = null;
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPath = false;
      fileName = path != null
          ? path.split('/').last
          : paths != null
              ? paths.keys.toString()
              : '...';
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
          child: new Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: new SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new DropdownButton(
                    hint: new Text('Select file type'),
                    value: fileType,
                    items: <DropdownMenuItem>[
                      new DropdownMenuItem(
                        child: new Text('Audio'),
                        value: FileType.audio,
                      ),
                      new DropdownMenuItem(
                        child: new Text('Image'),
                        value: FileType.image,
                      ),
                      new DropdownMenuItem(
                        child: new Text('Video'),
                        value: FileType.video,
                      ),
                      new DropdownMenuItem(
                        child: new Text('Any'),
                        value: FileType.any,
                      ),
                    ],
                    onChanged: (value) => setState(() {
                          fileType = value;
                        })),
              ),
              new ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 200.0),
                child: new SwitchListTile.adaptive(
                  title: new Text('Pick multiple files',
                      textAlign: TextAlign.right),
                  onChanged: (bool value) =>
                      setState(() => isMultiPick = value),
                  value: isMultiPick,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: new RaisedButton(
                  onPressed: () => _openFileExplorer(),
                  child: new Text("Open file picker"),
                ),
              ),
              new Builder(
                builder: (BuildContext context) => isLoadingPath
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: const CircularProgressIndicator())
                    : path != null || paths != null
                        ? new Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: new Scrollbar(
                                child: new ListView.separated(
                              itemCount: paths != null && paths.isNotEmpty
                                  ? paths.length
                                  : 1,
                              itemBuilder: (BuildContext context, int index) {
                                final bool isMultiPath =
                                    paths != null && paths.isNotEmpty;
                                final int fileNo = index + 1;
                                final String name = 'File $fileNo : ' +
                                    (isMultiPath
                                        ? paths.keys.toList()[index]
                                        : fileName ?? '...');
                                final filePath = isMultiPath
                                    ? paths.values.toList()[index].toString()
                                    : path;
                                return new ListTile(
                                  title: new Text(
                                    name,
                                  ),
                                  subtitle: new Text(filePath),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      new Divider(),
                            )),
                          )
                        : new Container(),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
