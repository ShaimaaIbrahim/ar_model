import '../../core/services/image_picker_service.dart';

class PickImageUseCase {
  final ImagePickerService repository;

  // We rely on ImagePickerService which acts as a repository for picking images
  PickImageUseCase(this.repository);

  /// Executes the usecase to pick an image.
  Future<String?> call() async {
    return await repository.pickImageFromGallery();
  }
}
