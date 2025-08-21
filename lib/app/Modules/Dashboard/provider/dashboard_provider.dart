

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashBoardNotifier extends ChangeNotifier{
  DashBoardNotifier();
  

}

final dashboard_Provider = StateProvider<DashBoardNotifier>((ref){
  return DashBoardNotifier();
});