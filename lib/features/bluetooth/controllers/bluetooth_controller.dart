import 'dart:typed_data' show Uint8List;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BluetoothController extends GetxController {
  final ImagePicker _picker;
  BluetoothController({required ImagePicker picker}) : _picker = picker;

  Uint8List? _selectedImageBytes;
  Rx<XFile?> selectedImage = Rx(null);

  void pickImageFromCamera() => _pickImage(ImageSource.camera);
  void pickImageFromGallery() => _pickImage(ImageSource.gallery);

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (file == null) return;
    selectedImage.value = file;
    final bytes = await file.readAsBytes();
    _selectedImageBytes = bytes;
  }
}
