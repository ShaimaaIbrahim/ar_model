import 'package:equatable/equatable.dart';

abstract class ArImageState extends Equatable {
  const ArImageState();

  @override
  List<Object?> get props => [];
}

class ArImageInitial extends ArImageState {}

class ArImagePicking extends ArImageState {}

class ArImagePicked extends ArImageState {
  final String imagePath;

  const ArImagePicked({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class ArImageError extends ArImageState {
  final String message;

  const ArImageError({required this.message});

  @override
  List<Object?> get props => [message];
}
