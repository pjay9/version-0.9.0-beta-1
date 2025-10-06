// lib/services/ml_service.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  // Configuration for your TFLite model
  final String modelPath = 'assets/car_parts.tflite';
  final String labelsPath = 'assets/labels.txt';
  final int inputSize = 224; // Assuming 224x224 input size
  final double mean = 127.5;
  final double std = 127.5;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset(modelPath);
      print('TFLite model loaded successfully.');

      // Load labels
      final labelData = await rootBundle.loadString(labelsPath);
      _labels = labelData.split('\n').map((s) => s.trim()).toList();
      _labels.removeWhere((s) => s.isEmpty); // Remove any empty lines
      print('Labels loaded: ${_labels.length} entries.');

      _isInitialized = true;
    } catch (e) {
      print('Failed to load TFLite model or labels: $e');
      _isInitialized = false;
    }
  }

  // Converts XFile from camera to a TFLite-compatible tensor buffer
  Uint8List _imageToByteListFloat(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);

        // Normalize the pixel values
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future<String> recognizePart(XFile imageFile) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return 'Initialization Failed. Check console.';
    }

    try {
      // 1. Read and decode the image
      final file = File(imageFile.path);
      img.Image? originalImage = img.decodeImage(file.readAsBytesSync());
      if (originalImage == null) return 'Image decoding failed.';

      // 2. Resize the image to model input size
      img.Image resizedImage = img.copyResize(originalImage,
          width: inputSize, height: inputSize);

      // 3. Prepare the input tensor
      var inputBytes = _imageToByteListFloat(resizedImage, inputSize);

      // Determine the output shape dynamically
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      var outputBuffer = Tensor.fromList(
          _interpreter!.getOutputTensor(0).type, List.filled(outputShape.reduce((a, b) => a * b), 0));

      // 4. Run inference
      _interpreter!.run(inputBytes.buffer, outputBuffer.data);

      // 5. Process the output (find the class with the highest confidence)
      List<double> result = outputBuffer.data.buffer.asFloat32List().toList();
      double maxScore = -1;
      int maxIndex = -1;

      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxScore) {
          maxScore = result[i];
          maxIndex = i;
        }
      }

      if (maxIndex >= 0 && maxIndex < _labels.length) {
        print('Detected Part: ${_labels[maxIndex]} with confidence ${maxScore.toStringAsFixed(2)}');
        return _labels[maxIndex];
      } else {
        return 'Recognition Failed (Index Out of Bounds)';
      }
    } catch (e) {
      print('Error during recognition: $e');
      return 'Recognition Error: $e';
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}