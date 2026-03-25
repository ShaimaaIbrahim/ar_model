import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/pick_image_usecase.dart';
import 'ar_image_event.dart';
import 'ar_image_state.dart';

class ArImageBloc extends Bloc<ArImageEvent, ArImageState> {
  final PickImageUseCase pickImageUseCase;

  ArImageBloc({required this.pickImageUseCase}) : super(ArImageInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<ClearImageEvent>(_onClearImage);
  }

  Future<void> _onPickImage(PickImageEvent event, Emitter<ArImageState> emit) async {
    emit(ArImagePicking());
    try {
      final String? imagePath = await pickImageUseCase();
      if (imagePath != null && imagePath.isNotEmpty) {
        emit(ArImagePicked(imagePath: imagePath));
      } else {
        // User canceled picking
        emit(ArImageInitial());
      }
    } catch (e) {
      emit(ArImageError(message: 'Failed to pick image: $e'));
    }
  }

  void _onClearImage(ClearImageEvent event, Emitter<ArImageState> emit) {
    emit(ArImageInitial());
  }
}
