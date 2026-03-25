import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ar_image_bloc.dart';
import '../bloc/ar_image_event.dart';
import '../bloc/ar_image_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ar_view_page.dart' deferred as ar_page;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Image Picker'),
      ),
      body: Center(
        child: BlocBuilder<ArImageBloc, ArImageState>(
          builder: (context, state) {
            if (state is ArImagePicking) {
              return const CircularProgressIndicator();
            } else if (state is ArImagePicked) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(state.imagePath)),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('Enter AR View'),
                    onPressed: () async {
                      PermissionStatus status = await Permission.camera.request();
                      if (status.isGranted) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
                          
                          try {
                            await ar_page.loadLibrary();
                            if (context.mounted) {
                              Navigator.pop(context); // hide loading
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ar_page.ArViewPage(imagePath: state.imagePath),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to load AR module.')),
                              );
                            }
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera permission is required for AR.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<ArImageBloc>().add(ClearImageEvent());
                    },
                    child: const Text('Clear Selection'),
                  )
                ],
              );
            } else if (state is ArImageError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    state.message, 
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ArImageBloc>().add(PickImageEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              );
            }
            // Initial State
            return ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pick Image from Gallery'),
              onPressed: () {
                context.read<ArImageBloc>().add(PickImageEvent());
              },
            );
          },
        ),
      ),
    );
  }
}
