import 'package:flutter/material.dart';

class TextController extends StatelessWidget {

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: controller),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.clear();
                },
                child: Text('click me clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
