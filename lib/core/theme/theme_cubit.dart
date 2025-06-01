import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  void toggle({bool? isChanged}) {
    emit(isChanged ?? false ? ThemeMode.dark : ThemeMode.light);
  }
}
