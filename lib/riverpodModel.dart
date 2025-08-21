import 'package:flutter/material.dart';

class Riverpodmodel extends ChangeNotifier{
  int counter;
  Riverpodmodel({required this.counter});

  void increment(){
    counter++;
    notifyListeners();
  }

  void decrement(){
    if(counter > 0){
    counter--;
    }
    notifyListeners();
  }
}