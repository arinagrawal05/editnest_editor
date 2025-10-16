import 'package:celebrare_editor/components.dart';
import 'package:celebrare_editor/edit_class.dart';
import 'package:celebrare_editor/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

// ignore: use_key_in_widget_constructors
class EditorScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  EditableItem? activeItem;
  Offset initPosition = const Offset(20, 20);
  Offset currentPosition = const Offset(20, 20);
  bool inAction = false;
  List<EditableItem> stackData = [];
  String currentText = "Sample";
  Color currentColor = const Color(0xff000000);
  Color pickerColor = Colors.green;
  double currentFontSize = 24.0;
  int currentFontFamily = 0;

  List<EditableItem> undoStack = [];
  List<EditableItem> redoStack = [];

  List<String> fontFamilyList = [
    "Lato",
    "Montserrat",
    "Lobster",
    "Pacifico",
    "Spectral SC",
    "Dancing Script",
    "Oswald",
    "Bangers",
    "Turret Road",
    "Anton"
  ];
  int findIndexOfString(List<String> stringList, String targetString) {
    for (int i = 0; i < stringList.length; i++) {
      if (stringList[i] == targetString) {
        return i; // Found the target string, return its index
      }
    }
    return 0; // If the target string is not found, return -1
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          history(),
          Column(
            children: [
              contributeButton(),
              canvasBoard(),
            ],
          ),
          toolbar(context),
        ],
      ),
    );
  }

  Widget toolbar(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height - 60,
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Toolbar",
              style: GoogleFonts.montserrat(fontSize: 22),
            ),
          ),
          contentTextField(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                colorPalette(currentColor),
                const SizedBox(
                  width: 20,
                ),
                colorPicker(context),
              ],
            ),
          ),
          Row(
            children: [
              slider(),
              fontShowcase(currentFontSize.toInt().toString()),
            ],
          ),
          fontGrid(),
          sample(),
          const Spacer(),
          addButton(),
          const SizedBox(
            height: 20,
          ),
          addBackground(),
          const SizedBox(
            height: 20,
          ),
          saveImageButton(),
        ],
      ),
    );
  }

  void undo() {
    setState(() {
      if (stackData.isNotEmpty) {
        redoStack.add(stackData.removeLast());
      }
    });
  }

  void redo() {
    setState(() {
      if (redoStack.isNotEmpty) {
        stackData.add(redoStack.removeLast());
      }
    });
  }

  Widget history() {
    return SizedBox(
      width: canvasWidth / 4 + 50,
      child: ListView.builder(
        // shrinkWrap: true,
        itemCount: stackData.length,
        itemBuilder: (context, index) {
          return Container(
            height: canvasHeight / 4,
            width: canvasWidth / 4,
            padding: EdgeInsets.only(
                left: stackData[stackData.length - index - 1].position.dx *
                    canvasWidth /
                    4,
                top: stackData[stackData.length - index - 1].position.dy *
                    canvasHeight /
                    4),
            margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              stackData[stackData.length - index - 1].value,
              style: GoogleFonts.getFont(fontFamilyList[
                      stackData[stackData.length - index - 1].fontFamily])
                  .copyWith(
                      color: stackData[stackData.length - index - 1].color,
                      fontSize:
                          stackData[stackData.length - index - 1].fontSize / 4),
            ),
          );
        },
      ),
    );
  }

  TextField contentTextField() {
    return TextField(
      autofocus: true,
      textAlign: TextAlign.center,
      maxLines: 3,
      minLines: 1,
      decoration: const InputDecoration(
        hintText: "Write Some Text",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      onChanged: (input) {
        if (mounted) {
          setState(() {
            currentText = input;
          });
        }
      },
    );
  }

  Widget addButton() {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: () {
            setState(() {
              activeItem = null;
            });

            if (currentText.isNotEmpty) {
              setState(() {
                stackData.add(EditableItem()
                  ..value = currentText
                  ..color = currentColor
                  ..fontSize = currentFontSize
                  ..fontFamily = currentFontFamily);
              });
            }
          },
          child: Text(
            "Add This Design",
            style:
                GoogleFonts.montserrat(color: Color.fromARGB(255, 62, 98, 194)),
          ),
        )),
      ],
    );
  }

  Widget addBackground() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: pickImage,
            child: Text(
              'Pick Background Image',
              style: GoogleFonts.montserrat(
                  color: Color.fromARGB(255, 62, 98, 194)),
            ),
          ),
        ),
      ],
    );
  }

  Widget saveImageButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              Utils.downloadImage(screenshotController);
              // // Capture screenshot
              // Uint8List? capturedImageBytes =
              //     await screenshotController.capture();

              // if (capturedImageBytes != null) {
              //   // Convert to Image from image package
              //   img.Image image = img.decodeImage(capturedImageBytes)!;

              //   // Save image to file
              //   Utils.saveImage(image);
              // }
            },
            child: Text(
              'Save Image',
              style: GoogleFonts.montserrat(
                  color: Color.fromARGB(255, 62, 98, 194)),
            ),
          ),
        ),
      ],
    );
  }

  Text sample() {
    return Text(
      currentText,
      style: GoogleFonts.getFont(fontFamilyList[currentFontFamily])
          .copyWith(color: currentColor, fontSize: currentFontSize),
    );
  }

  Widget fontGrid() {
    return SizedBox(
      width: double.infinity,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        padding: const EdgeInsets.all(8.0), // padding around the grid
        itemCount: fontFamilyList.length, // total number of items
        itemBuilder: (context, index) {
          return Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentFontFamily = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: index == currentFontFamily
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Text(
                  'Aa',
                  style: GoogleFonts.getFont(fontFamilyList[index]).copyWith(
                      color: index == currentFontFamily
                          ? Colors.black
                          : Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Container colorPicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: canvasColor, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(3),
      child: IconButton(
        icon: const Icon(
          Icons.color_lens_outlined,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  'Pick a color!',
                  style: GoogleFonts.montserrat(color: Colors.black),
                ),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (color) {
                      setState(() {
                        pickerColor = color;
                      });
                    },
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(
                      'Pick Color',
                      style: GoogleFonts.montserrat(color: Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        currentColor = pickerColor;
                      });
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Expanded slider() {
    return Expanded(
      child: Slider(
          value: currentFontSize,
          min: 14,
          max: 74,
          activeColor: Colors.black,
          inactiveColor: Colors.black.withOpacity(0.4),
          onChanged: (input) {
            setState(() {
              currentFontSize = input;
            });
          }),
    );
  }

  GestureDetector canvasBoard() {
    return GestureDetector(
      onScaleStart: (details) {
        if (activeItem == null) return;
        initPosition = details.focalPoint;
        currentPosition = activeItem!.position;
      },
      onScaleUpdate: (details) {
        if (activeItem == null) return;
        final delta = details.focalPoint - initPosition;
        final left = (delta.dx / canvasWidth) + currentPosition.dx;
        final top = (delta.dy / canvasHeight) + currentPosition.dy;

        activeItem!.position = Offset(left, top);
      },
      onTapUp: (details) {
        // Check if tapped on an existing item
        for (EditableItem item in stackData) {
          if (Utils.isTapInsideItem(details.localPosition, item)) {
            showEditDialog(item);
            break;
          }
        }
      },
      child: Container(
        // Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: canvasHeight,
        width: canvasWidth,
        child: Stack(
          children: [
            Screenshot(
              controller: screenshotController,
              child: SizedBox(
                // margin: const EdgeInsets.symmetric(vertical: 100),
                height: canvasHeight,
                width: canvasWidth,
                child: Stack(
                  children: [
                    Container(
                      decoration: imageBytes != null
                          ? BoxDecoration(
                              image: DecorationImage(
                                  image: MemoryImage(imageBytes!),
                                  fit: BoxFit.cover),
                              color: canvasColor,
                              borderRadius: BorderRadius.circular(10))
                          : BoxDecoration(
                              // image: const DecorationImage(
                              //     image: NetworkImage(
                              //       "https://images.pexels.com/photos/735277/pexels-photo-735277.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                              //     ),
                              //     fit: BoxFit.cover),
                              color: canvasColor,
                              borderRadius: BorderRadius.circular(10)),
                    ),
                    ...stackData.map(buildItemWidget),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      undo();
                    },
                    child: const Icon(Icons.undo),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      redo();
                    },
                    child: const Icon(Icons.redo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(EditableItem item) {
    TextEditingController controller = TextEditingController(text: item.value);

    showDialog(
      context: context,
      builder: (ctx) {
        String selectedFontFamily = fontFamilyList[item.fontFamily];
        Color selectedColor = item.color;
        double selectedFontSize = item.fontSize;
        return AlertDialog(
          title: Text(
            'Edit Font Properties',
            style: GoogleFonts.montserrat(color: Colors.black),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  TextField(
                    controller: controller,
                    // onChanged: (value) {
                    //   setState(() {
                    //     item.value = value;
                    //   });
                    // },
                    decoration: InputDecoration(
                      labelText: 'Enter Text',
                      labelStyle: GoogleFonts.montserrat(color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                            value: selectedFontSize,
                            min: 14,
                            max: 74,
                            activeColor: Colors.black,
                            inactiveColor: Colors.black.withOpacity(0.4),
                            onChanged: (input) {
                              setState(() {
                                selectedFontSize = input;
                              });
                            }),
                      ),
                      fontShowcase(selectedFontSize.toInt().toString())
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          value: selectedFontFamily,
                          onChanged: (String? value) {
                            setState(() {
                              selectedFontFamily = value!;
                            });
                          },
                          items: fontFamilyList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          hint: Text(
                            'Font Family',
                            style: GoogleFonts.montserrat(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    pickerAreaHeightPercent: 0.8,
                  ),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.all(30),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the button color to red
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              onPressed: () {
                onDelete(item);
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              child: Text(
                'Apply Changes',
                style: GoogleFonts.montserrat(color: Colors.black),
              ),
              onPressed: () {
                setState(() {
                  item.value = controller.text;
                  item.color = selectedColor;
                  item.fontFamily =
                      findIndexOfString(fontFamilyList, selectedFontFamily);
                  item.fontSize = selectedFontSize;
                });
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onDelete(EditableItem item) {
    setState(() {
      stackData.remove(item);
      activeItem = null;
    });
  }

  Uint8List? imageBytes;

  Future<void> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          imageBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }

  Widget buildItemWidget(EditableItem e) {
    return Positioned(
      top: e.position.dy * canvasHeight,
      left: e.position.dx * canvasWidth,
      child: Listener(
        onPointerDown: (details) {
          if (inAction) return;
          inAction = true;
          activeItem = e;
          initPosition = details.position;
          currentPosition = e.position;
        },
        onPointerUp: (details) {
          inAction = false;

          setState(() {
            activeItem = null;
          });
        },
        onPointerCancel: (details) {},
        onPointerMove: (details) {
          if (e.position.dy >= 0.8 &&
              e.position.dx >= 0.0 &&
              e.position.dx <= 1.0) {
            setState(() {});
          } else {
            setState(() {});
          }
        },
        child: Text(
          e.value,
          style: GoogleFonts.getFont(fontFamilyList[e.fontFamily])
              .copyWith(color: e.color, fontSize: e.fontSize),
        ),
      ),
    );
  }
}
