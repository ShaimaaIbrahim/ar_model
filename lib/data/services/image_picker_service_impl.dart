import 'package:image_picker/image_picker.dart';
import '../../core/services/image_picker_service.dart';

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _imagePicker;

  ImagePickerServiceImpl({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        // Optional: Compress or define max width/height to optimize memory for AR 
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      return image?.path;
    } catch (e) {
      // Depending on the architecture, you could throw a custom Failure here
      throw Exception('Failed to pick image: $e');
    }
  }
}
