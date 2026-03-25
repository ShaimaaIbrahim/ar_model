import 'package:get_it/get_it.dart';
import 'core/services/image_picker_service.dart';
import 'data/services/image_picker_service_impl.dart';
import 'domain/usecases/pick_image_usecase.dart';
import 'presentation/bloc/ar_image_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => ArImageBloc(pickImageUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => PickImageUseCase(sl()));

  // Services
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
}
