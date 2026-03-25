import 'package:equatable/equatable.dart';

abstract class ArImageEvent extends Equatable {
  const ArImageEvent();

  @override
  List<Object> get props => [];
}

class PickImageEvent extends ArImageEvent {}

class ClearImageEvent extends ArImageEvent {}
