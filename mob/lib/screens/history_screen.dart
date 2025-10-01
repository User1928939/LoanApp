import 'package:flutter/material.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.trustBlue,
        title: const Text('History'),
      ),
      body: const Center(
        child: Text('History Screen'),
      ),
    );
  }
}
