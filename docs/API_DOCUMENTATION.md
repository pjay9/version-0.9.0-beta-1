# API Documentation

This document provides detailed API documentation for the service layer of Gen-AR Mechanic.

## Table of Contents

1. [MLService API](#mlservice-api)
2. [GeminiService API](#geminiservice-api)
3. [Error Handling](#error-handling)
4. [Usage Examples](#usage-examples)

## MLService API

### Overview

The `MLService` class handles TensorFlow Lite model inference for automotive part recognition.

**Location**: `lib/services/ml_service.dart`

### Class Definition

```dart
class MLService {
  // Properties
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;
  
  // Configuration
  final String modelPath = 'assets/car_parts.tflite';
  final String labelsPath = 'assets/labels.txt';
  final int inputSize = 224;
  final double mean = 127.5;
  final double std = 127.5;
}
```

### Methods

#### `initialize()`

Initializes the ML service by loading the TensorFlow Lite model and labels.

**Signature**:
```dart
Future<void> initialize() async
```

**Description**:
- Loads the TFLite model from assets
- Loads and parses the labels file
- Sets `_isInitialized` flag to true
- Handles initialization errors gracefully

**Returns**: `Future<void>`

**Throws**: 
- `Exception` if model or labels cannot be loaded

**Example**:
```dart
final mlService = MLService();
await mlService.initialize();
```

**Notes**:
- Safe to call multiple times (checks `_isInitialized`)
- Should be called before using `recognizePart()`

---

#### `recognizePart(XFile imageFile)`

Recognizes an automotive part from a captured image.

**Signature**:
```dart
Future<String> recognizePart(XFile imageFile) async
```

**Parameters**:
- `imageFile` (XFile): The image file captured from camera

**Description**:
1. Checks if service is initialized (initializes if not)
2. Reads and decodes the image file
3. Resizes image to model input size (224x224)
4. Preprocesses image (normalization)
5. Runs TFLite inference
6. Processes output to find highest confidence class
7. Returns the recognized part name

**Returns**: `Future<String>`
- Part name from labels file (e.g., "AC Compressor", "Radiator")
- Error message if recognition fails

**Possible Return Values**:
- `"AC Compressor"` - Successfully recognized part
- `"Initialization Failed. Check console."` - Model not loaded
- `"Image decoding failed."` - Invalid image file
- `"Recognition Failed (Index Out of Bounds)"` - Model output error
- `"Recognition Error: [error details]"` - Other errors

**Example**:
```dart
final mlService = MLService();
final imageFile = await cameraController.takePicture();
final partName = await mlService.recognizePart(imageFile);
print('Recognized: $partName');
```

**Error Handling**:
- Returns error message string instead of throwing exceptions
- Logs errors to console for debugging
- Gracefully handles null images and model errors

---

#### `dispose()`

Cleans up resources used by the ML service.

**Signature**:
```dart
void dispose()
```

**Description**:
- Closes the TFLite interpreter
- Releases model resources
- Should be called when service is no longer needed

**Example**:
```dart
mlService.dispose();
```

---

### Private Methods

#### `_imageToByteListFloat(img.Image image, int inputSize)`

Converts an image to a normalized float array for model input.

**Signature**:
```dart
Uint8List _imageToByteListFloat(img.Image image, int inputSize)
```

**Parameters**:
- `image`: Decoded image object
- `inputSize`: Target size (224)

**Returns**: `Uint8List` - Normalized image data

**Processing**:
- Converts RGB pixels to normalized float values
- Normalization: `(pixel - mean) / std`
- Mean: 127.5, Std: 127.5
- Output shape: [1, 224, 224, 3]

---

## GeminiService API

### Overview

The `GeminiService` class handles communication with Google Gemini API for generating repair guides.

**Location**: `lib/services/gemini_service.dart`

### Class Definition

```dart
class GeminiService {
  final String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=${ApiConfig.geminiApiKey}';
}
```

### Methods

#### `getRepairGuide(String partName, String userQuestion)`

Generates a detailed repair guide using Google Gemini API.

**Signature**:
```dart
Future<String> getRepairGuide(String partName, String userQuestion) async
```

**Parameters**:
- `partName` (String): The name of the recognized automotive part
- `userQuestion` (String): The user's question about the part

**Description**:
1. Constructs system prompt for expert mechanic persona
2. Constructs user prompt with part name and question
3. Creates JSON payload for API request
4. Makes HTTP POST request to Gemini API
5. Parses JSON response
6. Extracts and returns repair guide text

**Returns**: `Future<String>`
- AI-generated repair guide text
- Error message if API call fails

**Possible Return Values**:
- `"Step-by-step repair guide text..."` - Success
- `"Error: Could not reach AI service. Status code: [code]"` - HTTP error
- `"An error occurred during network communication: [error]"` - Network/parse error

**Example**:
```dart
final geminiService = GeminiService();
final guide = await geminiService.getRepairGuide(
  'AC Compressor',
  'Why is it making a loud noise?'
);
print(guide);
```

**Request Format**:
```json
{
  "contents": [
    {
      "parts": [
        {"text": "The user is looking at the 'AC Compressor'. The user is asking: 'Why is it making a loud noise?'. Provide a detailed, step-by-step guide..."}
      ]
    }
  ],
  "systemInstruction": {
    "parts": [
      {"text": "You are a professional, expert mechanic. Your response must be direct, clear, and focused on practical steps..."}
    ]
  }
}
```

**Response Format**:
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {"text": "The repair guide text..."}
        ]
      }
    }
  ]
}
```

**Error Handling**:
- Catches HTTP exceptions
- Handles non-200 status codes
- Returns user-friendly error messages
- Logs errors for debugging

**Status Code Handling**:
- `200`: Success - returns guide text
- `400`: Bad request - returns error message
- `401`: Unauthorized - API key issue
- `429`: Rate limit exceeded
- `500+`: Server error

---

## Error Handling

### Error Types

#### MLService Errors

1. **Initialization Errors**
   - Model file not found
   - Labels file not found
   - Invalid model format
   - Insufficient memory

2. **Recognition Errors**
   - Image decoding failure
   - Invalid image format
   - Model inference failure
   - Output parsing errors

#### GeminiService Errors

1. **Network Errors**
   - No internet connection
   - Timeout
   - DNS resolution failure

2. **API Errors**
   - Invalid API key (401)
   - Rate limit exceeded (429)
   - Server errors (500+)
   - Invalid request format (400)

3. **Parse Errors**
   - Invalid JSON response
   - Missing expected fields
   - Malformed response structure

### Error Response Format

All service methods return error messages as strings rather than throwing exceptions. This allows the UI layer to handle errors gracefully.

**Error Message Patterns**:
- MLService: `"Recognition Error: [details]"`
- GeminiService: `"Error: [description]. Status code: [code]"` or `"An error occurred during network communication: [details]"`

### Best Practices

1. **Always Check Return Values**
   ```dart
   final result = await service.method();
   if (result.startsWith('Error:') || result.startsWith('Recognition Error:')) {
     // Handle error
   }
   ```

2. **Validate Inputs Before Service Calls**
   ```dart
   if (partName.isEmpty || question.isEmpty) {
     return 'Invalid input';
   }
   ```

3. **Handle Network Connectivity**
   - Check internet connection before API calls
   - Provide offline fallback when possible

4. **Log Errors for Debugging**
   - Use `print()` or logging framework
   - Include context information

---

## Usage Examples

### Complete Workflow Example

```dart
import 'package:camera/camera.dart';
import 'services/ml_service.dart';
import 'services/gemini_service.dart';

// Initialize services
final mlService = MLService();
final geminiService = GeminiService();

// Initialize ML service
await mlService.initialize();

// Capture image
final imageFile = await cameraController.takePicture();

// Recognize part
final partName = await mlService.recognizePart(imageFile);
if (partName.startsWith('Recognition Error')) {
  print('ML recognition failed: $partName');
  return;
}

// Generate repair guide
final question = 'What is the problem?';
final guide = await geminiService.getRepairGuide(partName, question);
if (guide.startsWith('Error:')) {
  print('API call failed: $guide');
  return;
}

// Display results
print('Part: $partName');
print('Guide: $guide');
```

### Error Handling Example

```dart
Future<String> processRepairRequest(XFile image, String question) async {
  try {
    // ML Recognition
    final partName = await mlService.recognizePart(image);
    
    if (partName.contains('Error') || partName.contains('Failed')) {
      return 'Could not identify the part. Please ensure the part is clearly visible.';
    }
    
    // Validate inputs
    if (partName.isEmpty || question.isEmpty) {
      return 'Please provide both a part and a question.';
    }
    
    // Generate guide
    final guide = await geminiService.getRepairGuide(partName, question);
    
    if (guide.startsWith('Error:')) {
      if (guide.contains('Status code: 401')) {
        return 'API authentication failed. Please check your API key configuration.';
      } else if (guide.contains('Status code: 429')) {
        return 'Too many requests. Please wait a moment and try again.';
      } else {
        return 'Unable to generate repair guide. Please check your internet connection.';
      }
    }
    
    return guide;
    
  } catch (e) {
    return 'An unexpected error occurred: ${e.toString()}';
  }
}
```

### Service Lifecycle Management

```dart
class RepairServiceManager {
  final MLService _mlService = MLService();
  final GeminiService _geminiService = GeminiService();
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _mlService.initialize();
      _isInitialized = true;
    }
  }
  
  Future<String> processRepair(XFile image, String question) async {
    await initialize();
    
    final partName = await _mlService.recognizePart(image);
    if (partName.contains('Error')) {
      return partName;
    }
    
    return await _geminiService.getRepairGuide(partName, question);
  }
  
  void dispose() {
    _mlService.dispose();
  }
}
```

---

## API Configuration

### Gemini API Setup

1. **Get API Key**
   - Visit: https://makersuite.google.com/app/apikey
   - Create API key
   - Copy key

2. **Configure in Code**
   - Update `lib/config/api_config.dart`
   - Or use environment variables (recommended)

3. **API Endpoint**
   - Base URL: `https://generativelanguage.googleapis.com/v1beta/`
   - Model: `gemini-2.5-flash-preview-05-20`
   - Method: POST
   - Authentication: API key in query parameter

### ML Model Setup

1. **Model Requirements**
   - Format: TensorFlow Lite (.tflite)
   - Input: 224x224 RGB image
   - Output: Class probabilities array

2. **Labels File**
   - Format: One class name per line
   - Encoding: UTF-8
   - Location: `assets/labels.txt`

---

## Performance Considerations

### MLService Performance

- **Inference Time**: ~30-50ms per image (device dependent)
- **Memory Usage**: ~50-100MB (model + image processing)
- **Optimization**: Consider moving to Dart Isolate for async processing

### GeminiService Performance

- **API Latency**: ~1-3 seconds (network dependent)
- **Request Size**: ~500 bytes - 2KB
- **Response Size**: ~1-5KB (varies with guide length)
- **Optimization**: Implement caching for repeated queries

---

## Future API Enhancements

### Planned Improvements

1. **Retry Logic**: Automatic retry with exponential backoff
2. **Caching**: Cache API responses locally
3. **Batch Processing**: Process multiple images
4. **Streaming Responses**: Real-time guide generation
5. **Confidence Scores**: Return confidence with part recognition
6. **Multiple Predictions**: Return top-N part predictions

---

## Troubleshooting

### Common Issues

**ML Service not initializing**
- Check model file exists in assets
- Verify pubspec.yaml includes assets
- Check model file format

**Gemini API returning errors**
- Verify API key is correct
- Check API quota/limits
- Verify network connectivity
- Check request format

**Slow performance**
- Consider model quantization
- Optimize image preprocessing
- Use isolates for async processing
- Cache API responses

---

**Last Updated**: 2026  
**API Version**: 1.0

