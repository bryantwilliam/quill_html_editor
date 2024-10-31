// ignore_for_file: implementation_imports
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:quill_html_editor/src/widgets/webviewx/src/webviewx_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ///[controller] create a QuillEditorController to access the editor methods
  ///late QuillEditorController controller;

  ///[customToolBarList] pass the custom toolbarList to show only selected styles in the editor

  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.align,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.clean,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
  ];

  final _toolbarColor = Colors.grey.shade200;
  final _backgroundColor = Colors.white70;
  final _toolbarIconColor = Colors.black87;
  final _editorTextStyle = const TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto');
  final _hintTextStyle = const TextStyle(
      fontSize: 18, color: Colors.black38, fontWeight: FontWeight.normal);

  bool _hasFocus = false;

  int selectedTextlength = 0;
  int selectedTextPosition = 0;
  Duration positioning = Duration.zero;
  // final GlobalKey _textKey = GlobalKey();
  final List<Comment> _comments = [];
  final TextEditingController commentController = TextEditingController();
  final QuillEditorController controller = QuillEditorController();
  late YoutubePlayerController _youtubecontroller;
  ScrollController scrollController = ScrollController();
  num _progress = 0.0;
  num scrollPosition = 0.0;

  void _addComment(String text) {
    final comment = Comment(text: text);

    setState(() {
      _comments.add(comment);
      commentController.clear();
      selectedTextlength = 0;
    });
  }

  showdialog(BuildContext context, String youtubeLink) {
    print(
        'trying to get the converted link of the video link ${YoutubePlayer.convertUrlToId(youtubeLink)}');
    _youtubecontroller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(
                'https://www.youtube.com/embed/dQw4w9WgXcQ') ??
            '',
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ));
    //..addListener(listener);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
            child: YoutubePlayerBuilder(
          onExitFullScreen: () {
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          },
          player: YoutubePlayer(
            controller: _youtubecontroller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            topActions: const [],
            onReady: () {
              // _youtubecontroller.updateValue(YoutubePlayerValue(position: positioning));
              _youtubecontroller.seekTo(positioning, allowSeekAhead: true);
            },
            onEnded: (data) {},
          ),
          builder: (context, player) {
            // _youtubecontroller.addListener(positionListener);
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3.5,
                  color: Colors.transparent,
                  child: player,
                ),
                Positioned(
                  child: IconButton(
                      onPressed: () {
                        positioning = _youtubecontroller.value.position;

                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 35,
                        color: Colors.white,
                      )),
                )
              ],
            );
          },
        ));
      },
    );
  }

  showModalSheetScreen(int index, int length) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).canvasColor,
                      blurRadius: 0.1,
                      spreadRadius: 0.4,
                      offset: const Offset(2, 6),
                    )
                  ]),
              child: Wrap(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 14.0, left: 9, right: 9),
                    child: Column(
                      children: [
                        TextField(
                          controller: commentController,
                          autofocus: true,
                          decoration: InputDecoration(
                              hintText: 'Make your comment...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                        const SizedBox(
                          height: 9,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () {
                                  _addComment(commentController.text);
                                  controller.setFormat(
                                      format: 'background',
                                      value: '#FF9800',
                                      index: index,
                                      length: length);
                                  Navigator.pop(context);
                                },
                                child: const Text('Comment'))
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          //: const SizedBox.shrink(): const SizedBox.shrink()
        });
  }

  @override
  void initState() {
    //controller.setScrollPosition(scrollPosition)
    WidgetsBinding.instance.addObserver(this);
    controller.onTextChanged((text) {
      debugPrint('listening to $text');
    });
    controller.onEditorLoaded(() {
      debugPrint('Editor Loaded :)');
    });
    controller.setText(htmlContent);
    // _youtubecontroller.addListener(positionListener);
    super.initState();
  }

  @override
  void dispose() {
    //  _youtubecontroller.removeListener(positionListener);
    WidgetsBinding.instance.removeObserver(this);
    _youtubecontroller.dispose();
    //  scrollController.removeListener(scrollListener);
    scrollController.dispose();

    /// please do not forget to dispose the controller
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      positioning = _youtubecontroller.value.position;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: selectedTextlength >= 1
            ? !kIsWeb
                ? ElevatedButton(
                    onPressed: () async {
                      final selection = await controller.getSelectionRange();
                      if (selection.length == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Select text to comment on')),
                        );
                      } else {
                        showModalSheetScreen(
                            selectedTextPosition, selectedTextlength);
                      }
                    },
                    child: const Text('Add Comment'))
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: kIsWeb
            ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        toolbar(),
                        LinearProgressIndicator(
                          value: _progress.toDouble(),
                          backgroundColor: Colors.lightGreen,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                      //height: MediaQuery.of(context).size.height,
                      child:
                          //Column(children: [//  Expanded(child:
                          Row(
                    children: [
                      Flexible(flex: 3, child: editor()),
                      _comments.isEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.only(
                                  right: 15, top: 10, bottom: 10),
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.height,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  return commentTile(_comments[index].text);
                                },
                              ))
                    ],
                  )
                      //   ) //  ],),
                      )
                ],
              )
            : Column(
                children: [
                  toolbar(),
                  LinearProgressIndicator(
                    value: _progress.toDouble(),
                    backgroundColor: Colors.lightGreen,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Expanded(flex: 10, child: editor()),
                ],
              ),
        bottomNavigationBar: kIsWeb
            ? selectedTextlength >= 1
                ? Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).canvasColor,
                            blurRadius: 0.1,
                            spreadRadius: 0.4,
                            offset: const Offset(2, 6),
                          )
                        ]),
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14.0, left: 9, right: 9),
                          child: Column(
                            children: [
                              TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                    hintText: 'Make your comment...',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                              ),
                              const SizedBox(
                                height: 9,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () {
                                        _addComment(commentController.text);
                                        controller.setFormat(
                                            format: 'background',
                                            value: '#FF9800');
                                      },
                                      child: const Text('Comment'))
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.maxFinite,
                    color: _toolbarColor,
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      children: [
                        textButton(
                            text: 'Set Text',
                            onPressed: () {
                              setHtmlText(htmlContent);
                              //setHtmlText('This text is set by you 🫵');
                            }),
                        textButton(
                            text: 'Get Text',
                            onPressed: () {
                              getHtmlText();
                            }),
                        textButton(
                            text: 'Insert Video',
                            onPressed: () {
                              ////insert
                              insertVideoURL(
                                  'https://www.youtube.com/watch?v=4AoFA19gbLo');
                              insertVideoURL('https://vimeo.com/440421754');
                              insertVideoURL(
                                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
                            }),
                        textButton(
                            text: 'Insert Image',
                            onPressed: () {
                              controller.embedImage(htmlContent);
                              // insertNetworkImage(
                              //     'https://i.imgur.com/0DVAOec.gif');
                            }),
                        textButton(
                            text: 'Insert Index',
                            onPressed: () {
                              insertHtmlText(
                                  "This text is set by the insertText method",
                                  index: 10);
                            }),
                        textButton(
                            text: 'Undo',
                            onPressed: () {
                              controller.undo();
                            }),
                        textButton(
                            text: 'Redo',
                            onPressed: () {
                              controller.redo();
                            }),
                        textButton(
                            text: 'Clear History',
                            onPressed: () async {
                              controller.clearHistory();
                            }),
                        textButton(
                            text: 'Clear Editor',
                            onPressed: () {
                              controller.clear();
                            }),
                        textButton(
                            text: 'Get Delta',
                            onPressed: () async {
                              var delta = await controller.getDelta();
                              debugPrint('delta');
                              debugPrint(jsonEncode(delta));
                            }),
                        textButton(
                            text: 'Set Delta',
                            onPressed: () {
                              final Map<dynamic, dynamic> deltaMap = {
                                "ops": [
                                  {
                                    "insert": {
                                      "video":
                                          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                                    }
                                  },
                                  {
                                    "insert": {
                                      "video":
                                          "https://www.youtube.com/embed/4AoFA19gbLo"
                                    }
                                  },
                                  {"insert": "Hello"},
                                  {
                                    "attributes": {"header": 1},
                                    "insert": "\n"
                                  },
                                  {"insert": "You just set the Delta text 😊\n"}
                                ]
                              };
                              controller.setDelta(deltaMap);
                            }),
                      ],
                    ))
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget commentTile(String comment) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(9),
      //height: 40,
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.09),
                offset: const Offset(0, 4),
                spreadRadius: 0,
                blurRadius: 24)
          ],
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(9)),
      child: Text(comment),
    );
  }

  Widget editor() {
    return QuillHtmlEditor(
      text: htmlContent,
      hintText: 'Hint text goes here',
      controller: controller,
      isEnabled: true,
      ensureVisible: false,
      minHeight: 500,
      autoFocus: false,
      textStyle: _editorTextStyle,
      hintTextStyle: _hintTextStyle,
      hintTextAlign: TextAlign.start,
      //padding: const EdgeInsets.only(left: 10, top: 10),
      hintTextPadding: const EdgeInsets.only(left: 20),
      backgroundColor: _backgroundColor,
      inputAction: InputAction.newline,
      onEditingComplete: (s) => debugPrint('Editing completed $s'),
      onFocusChanged: (focus) {
        debugPrint('has focus $focus');
        setState(() {
          _hasFocus = focus;
        });
      },
      onTextChanged: (text) => debugPrint('widget text change $text'),
      onEditorCreated: () {
        debugPrint('Editor has been loaded');
        // setHtmlText('Testing text on load');
        controller.setText(htmlContent);
      },
      onEditorResized: (height) => debugPrint('Editor resized $height'),
      onSelectionChanged: (sel) {
        debugPrint('index ${sel.index}, range ${sel.length}');
        setState(() {
          selectedTextlength = sel.length ?? 0;
          selectedTextPosition = sel.index ?? 0;
        });
      },
      navigationDelegate: (navigation) {
        print(navigation.content.source);
        if (navigation.content.source.contains('youtube.com')) {
          showdialog(context, navigation.content.source);
          return NavigationDecision.prevent;
        } else {
          print('other videos or link trying to play here also');
          return NavigationDecision.navigate;
        }
      },
      onVerticalScrollChange: (p0) {
        if (kIsWeb) {
          // print(
          //     'scrollTop is ${p0.scrollTop}, currentPosition ${p0.currentPosition}');
          setState(() {
            _progress = p0.currentPosition ?? 0.0;
            scrollPosition = p0.scrollTop ?? 0.0;
          });
        } else {
          // print(
          //     'scrollTop is ${p0.scrollTop}, currentPosition ${p0.currentPosition}');
          setState(() {
            _progress = p0.currentPosition ?? 0.0;
            scrollPosition = p0.scrollTop ?? 0.0;
          });
        }
      },
      lastScrollPosition: dataFromFirestore.lastScrollPosition,
      // youtubeLastPosition: dataFromFirestore.youtubeLastPosition
    );
  }

  Widget toolbar() {
    return ToolBar(
      toolBarColor: _toolbarColor,
      padding: const EdgeInsets.all(8),
      iconSize: 25,
      iconColor: _toolbarIconColor,
      activeIconColor: Colors.greenAccent.shade400,
      controller: controller,
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      customButtons: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
              color: _hasFocus ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(15)),
        ),
        InkWell(
            onTap: () => unFocusEditor(),
            child: const Icon(
              Icons.favorite,
              color: Colors.black,
            )),
        InkWell(
            onTap: () async {
              var selectedText = await controller.getSelectedText();
              debugPrint('selectedText $selectedText');
              var selectedHtmlText = await controller.getSelectedHtmlText();
              debugPrint('selectedHtmlText $selectedHtmlText');
            },
            child: const Icon(
              Icons.add_circle,
              color: Colors.black,
            )),
      ],
    );
  }

  Widget textButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: _toolbarIconColor,
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(color: _toolbarColor),
          )),
    );
  }

  ///[getHtmlText] to get the html text from editor
  void getHtmlText() async {
    String? htmlText = await controller.getText();
    debugPrint(htmlText);
  }

  ///[setHtmlText] to set the html text to editor
  void setHtmlText(String text) async {
    await controller.setText(text);
  }

  ///[insertNetworkImage] to set the html text to editor
  void insertNetworkImage(String url) async {
    await controller.embedImage(url);
  }

  ///[insertVideoURL] to set the video url to editor
  ///this method recognises the inserted url and sanitize to make it embeddable url
  ///eg: converts youtube video to embed video, same for vimeo
  void insertVideoURL(String url) async {
    await controller.embedVideo(url);
  }

  /// to set the html text to editor
  /// if index is not set, it will be inserted at the cursor postion
  void insertHtmlText(String text, {int? index}) async {
    await controller.insertText(text, index: index);
  }

  /// to clear the editor
  void clearEditor() => controller.clear();

  /// to enable/disable the editor
  void enableEditor(bool enable) => controller.enableEditor(enable);

  /// method to un focus editor
  void unFocusEditor() => controller.unFocus();

  void formatText() => controller.formatText();
}

class Comment {
  final String text;
  Comment({required this.text});
}

const String htmlContent = '''
<html>
<body>
  <article>
    <h1>Sample Article</h1>
    <p>This is a paragraph with some sample content.<br>The Next Line</p>
    <h2>List Example</h2>
    <ul>
      <li>List item 1</li>
      <li>List item 2</li>
      <li>List item 3</li>
    </ul>
    <h2>Table Example</h2>
    <table border="1">
      <tr>
        <td>Header 1</td>
        <td>Header 2</td>
        <td>Header 1</td>
        <td>Header 2</td>
      </tr>
      <tr>
        <td>Data 1</td>
        <td>Data 2</td>
        <td>Data 1</td>
        <td>Data 2</td>
      </tr>
    </table>
    <h2>Image Example</h2>
    <p><div><img src="https://hips.hearstapps.com/hmg-prod/images/bright-forget-me-nots-royalty-free-image-1677788394.jpg" alt="Flowers image"></div></p>
    <h2>IFrame Example</h2>
    <p><iframe width="520" height="300" src="https://www.youtube.com/embed/dQw4w9WgXcQ"></iframe></p>
    </ul>
    <h2>Video Example</h2>
    <video width="320" height="240" controls>
  <source src="http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4" type="video/mp4">
  Your browser does not support the video tag.
  <figcaption> Hello World</figcaption>
</video>
<h2>Another Video Example</h2>
    <video width="320" height="240" controls>
  <source src="http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4" type="video/mp4">
  Your browser does not support the video tag.
  <figcaption> Hello World</figcaption>
</video>
<h2>Another Random Image</h2>
<p><img src="https://www.shutterstock.com/shutterstock/photos/2056485080/display_1500/stock-vector-address-and-navigation-bar-icon-business-concept-search-www-http-pictogram-d-concept-2056485080.jpg" alt="Flowers image"></p>
  </article>
</body>
</html>
''';

final dataFromFirestore = QuillProgressController(
  lastScrollPosition: 450,
);
