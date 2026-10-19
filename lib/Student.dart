import 'package:flutter/widgets.dart';

class Student {
  String name;

  Student(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

}
