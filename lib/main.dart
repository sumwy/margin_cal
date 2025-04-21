import 'package:flutter/material.dart';
import 'package:myapp/spreadsheet_view.dart'; // Import the new view

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spreadsheet App', // Updated title
      theme: ThemeData(
        primarySwatch: Colors.green, // Changed theme color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SpreadsheetView(), // Use the SpreadsheetView as home
    );
  }
}
