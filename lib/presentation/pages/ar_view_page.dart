import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flash/ar_flutter_plugin_flash.dart';
import 'package:ar_flutter_plugin_flash/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flash/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_flash/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flash/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_flash/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class ArViewPage extends StatefulWidget {
  final String imagePath;

  const ArViewPage({super.key, required this.imagePath});

  @override
  State<ArViewPage> createState() => _ArViewPageState();
}

class _ArViewPageState extends State<ArViewPage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(">>>>>>>>>>>>>>>>0");
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Place Image in AR'),
        ),
        body: Stack(children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8.0),
                child: const Text('Tap on a detected plane to place the image.', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          )
        ]),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) async {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    try {
      await this.arSessionManager!.onInitialize(
            showFeaturePoints: false,
            showPlanes: true,
            showWorldOrigin: false,
            handlePans: true,
            handleRotation: true,
          );
      this.arObjectManager!.onInitialize();

      this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    } catch (e) {
      debugPrint(">>>>>>>>>>>>>>>>error: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AR Initialization Failed: Please ensure ARCore and Google Play Store are installed on this device."),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    // Attempt to place node on plane
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    debugPrint(">>>>>>>>>>>>>>>>:1");
    // In a generic AR Flutter Plugin, handling direct local image paths as primitive textures
    // is partially supported, depending on the fork. We create an ARNode and theoretically apply
    // the image as material. Due to plugin limitations, we will make sure the ARNode structure
    // receives the file path.
    var newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: widget.imagePath, 
        scale: math.Vector3(0.2, 0.2, 0.2),
        position: math.Vector3(
            singleHitTestResult.worldTransform.getColumn(3).x,
            singleHitTestResult.worldTransform.getColumn(3).y,
            singleHitTestResult.worldTransform.getColumn(3).z),
        rotation: math.Vector4(1.0, 0.0, 0.0, 0.0));

    bool? didAdd = await arObjectManager!.addNode(newNode);
    debugPrint(">>>>>>>>>>>>>>>>:2 $didAdd");
    if (didAdd == true) {
      nodes.add(newNode);
    }
  }
}
