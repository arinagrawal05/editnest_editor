import 'package:celebrare_editor/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Expanded colorPalette(Color currentColor) {
  return Expanded(
      child: Container(
    decoration: BoxDecoration(
        color: currentColor, borderRadius: BorderRadius.circular(6)),
    height: 20,
  ));
}

Widget contributeButton() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton.icon(
      onPressed: () {
        Utils.launchURL('https://github.com/arinagrawal05/editnest_editor');
      },
      icon: const Icon(Icons.favorite),
      label: Text('Contribute'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    ),
  );
}

Container fontShowcase(String value) {
  return Container(
      decoration: BoxDecoration(
          color: canvasColor, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(15),
      child: Text(
        value,
        style: GoogleFonts.montserrat(color: Colors.black),
      ));
}
