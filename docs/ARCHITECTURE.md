# Architecture Documentation (Target Final Design)

This document describes the **intended architecture for the final version** of Gen-AR Mechanic that we plan to deliver as our semester project. It is based on what we can realistically build in 1–2 months using Flutter, TensorFlow Lite, and Gemini, not on the full research-paper vision (no 5G MEC, no smart glasses, etc.).

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Patterns](#architecture-patterns)
3. [Component Architecture](#component-architecture)
4. [Data Flow](#data-flow)
5. [Technology Stack](#technology-stack)
6. [Design Decisions](#design-decisions)
7. [Future Architecture Improvements](#future-architecture-improvements)

## System Overview

Gen-AR Mechanic is a mobile application built with Flutter that combines:
- **Computer Vision**: TensorFlow Lite for on-device part recognition of a **small set** of engine components.
- **Generative AI**: Google Gemini API for contextual repair guidance based on the recognized part and user question.
- **Mobile Camera**: Real-time image capture and preview.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface Layer                  │
│  (Flutter Widgets: Screens, Widgets, State Management)  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                  Service Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ ML Service   │  │ Gemini       │  │ Camera       │ │
│  │ (TFLite)     │  │ Service      │  │ Service      │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              External Services & Resources               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ TFLite Model │  │ Gemini API   │  │ Device       │ │
│  │ (Assets)     │  │ (Cloud)      │  │ Camera       │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Architecture Patterns

### Targeted Layered Architecture

In the final version, the app will follow a simple but clear **layered architecture**:

1. **Presentation Layer**: Flutter widgets and screens
2. **Service Layer**: Business logic and external service integration
3. **Data Layer**: Local storage and API communication

### Design Patterns (Planned for Final State)

- **Service Pattern**: Encapsulated service classes for ML and API operations (already started).
- **Simple State Management (Provider/Riverpod)**: One or two app-level providers to keep camera/ML/AI state in sync.
- **Repository Pattern (Lightweight)**: A small repository that coordinates ML + Gemini + local history.
- **Dependency Injection via get_it (Optional but preferred)**: To make it easier to swap real services with mocks for testing.

## Component Architecture

### 1. Presentation Layer (Planned Final)

#### Screens

**MechanicHomePage** (`lib/screens/mechanic_home_page.dart`)
- Main application screen
- Manages camera controller
- Orchestrates image capture → ML recognition → AI guidance flow
- Handles user input and displays results

**Responsibilities**:
- Camera initialization and lifecycle management
- User interaction handling
- State management for UI updates
- Error handling and user feedback

#### Widgets

**CameraView** (`lib/widgets/camera_view.dart`)
- Displays camera preview or captured image
- Shows recognized part overlay
- Handles loading states

**ResponseCard** (`lib/widgets/response_card.dart`)
- Displays AI-generated repair guide
- Formats response text
- Provides visual feedback

### 2. Service Layer (Planned Final)

#### MLService (`lib/services/ml_service.dart`)

**Purpose**: Handle TensorFlow Lite model inference for part recognition.

**Key Responsibilities (Final)**:
- Load the `.tflite` model and labels from assets.
- Preprocess captured images (resize, normalize).
- Run inference and return the most likely part name and confidence.

**Planned Technical Details**:
- Input: 224x224 RGB image (normalized to [-1, 1]).
- Output: Class probabilities array.
- Processing: Initially on the main isolate; optionally moved to a background isolate if time permits.

#### GeminiService (`lib/services/gemini_service.dart`)

**Purpose**: Communicate with Google Gemini API for repair guidance.

**Key Responsibilities (Final)**:
- Build a safe, focused prompt using the recognized part name + user question.
- Call the Gemini endpoint with proper error handling and timeouts.
- Return a clean string that can be shown directly in the UI.

**API Integration (Target)**:
- Endpoint: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent`
- Method: POST
- Authentication: API key from environment/config.
- Request format: JSON with `systemInstruction` and `contents`.

### 3. Configuration Layer

#### ApiConfig (`lib/config/api_config.dart`)

**Purpose**: Centralized API configuration.

**Target Implementation**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
```

## Data Flow

### Image Capture to Repair Guide Flow

```
1. User Interaction
   └─> User taps "Capture & Get Repair Guide"
       │
2. Image Capture
   └─> CameraController.takePicture()
       └─> Returns XFile
           │
3. ML Recognition
   └─> MLService.recognizePart(XFile)
       ├─> Load image from file
       ├─> Preprocess (resize, normalize)
       ├─> Run TFLite inference
       └─> Return part name (String)
           │
4. AI Guidance Generation
   └─> GeminiService.getRepairGuide(partName, question)
       ├─> Construct prompt
       ├─> HTTP POST to Gemini API
       ├─> Parse JSON response
       └─> Return repair guide (String)
           │
5. UI Update
   └─> Update state with results
       └─> Display in ResponseCard widget
```

### Error Handling Flow

```
Error Occurs
   │
   ├─> Camera Error
   │   └─> Display error message in UI
   │
   ├─> ML Recognition Error
   │   └─> Return error message, continue to AI step
   │
   └─> API Error
       ├─> Network error → Show connectivity message
       ├─> API error → Show API-specific message
       └─> Parse error → Show generic error
```

## Technology Stack

### Core Framework

- **Flutter**: 3.5.3+
  - Cross-platform mobile framework
  - Dart programming language
  - Material Design 3

### Machine Learning

- **TensorFlow Lite**: On-device inference
  - Model format: `.tflite`
  - Package: `tflite_flutter`
  - Architecture: MobileNetV2 (planned/configured)

### AI Services

- **Google Gemini API**
  - Model: `gemini-2.5-flash-preview-05-20`
  - Communication: HTTP REST API
  - Package: `http`

### Camera & Media

- **Camera Plugin**: `camera: ^0.11.0+2`
  - Camera access and control
  - Image capture
  - Preview rendering

### Image Processing

- **Image Package**: `image: ^4.1.3` (to be added)
  - Image decoding
  - Resizing and preprocessing
  - Format conversion

### Utilities

- **Path Provider**: `path_provider: ^2.1.2`
  - File system access
  - Temporary directory management

## Design Decisions

### 1. On-Device ML Inference

**Decision**: Use TensorFlow Lite for local part recognition

**Rationale**:
- Low latency (no network delay)
- Works offline for recognition
- Privacy (images don't leave device)
- Cost-effective (no API calls for recognition)

**Trade-offs**:
- Model size limitations
- Limited to trained classes
- Requires model training and optimization

### 2. Cloud-Based AI Guidance

**Decision**: Use Gemini API for repair guide generation

**Rationale**:
- Access to large language model capabilities
- Contextual understanding
- No need to train language model
- Can be updated without app updates

**Trade-offs**:
- Requires internet connection
- API costs
- Latency (network request)
- Privacy considerations

### 3. Flutter Framework

**Decision**: Use Flutter for cross-platform development

**Rationale**:
- Single codebase for Android and iOS
- Good performance
- Rich widget library
- Active community

**Trade-offs**:
- Platform-specific features may require native code
- Larger app size compared to native

### 4. Current State Management

**Decision**: Use Flutter's built-in StatefulWidget

**Rationale**:
- Simple for initial implementation
- No additional dependencies
- Sufficient for current scope

**Planned Improvement**: Migrate to Provider/Riverpod for better scalability

## Future Architecture Improvements

### 1. State Management Migration

**Current**: StatefulWidget with setState()

**Planned**: Provider or Riverpod
- Centralized state management
- Better separation of concerns
- Easier testing
- Performance optimizations

### 2. Repository Pattern

**Planned Structure**:
```
repositories/
├── repair_guide_repository.dart
└── part_recognition_repository.dart
```

**Benefits**:
- Abstract data sources
- Easier to swap implementations
- Better testability

### 3. Dependency Injection

**Planned**: Using `get_it` package
- Service locator pattern
- Lazy initialization
- Easy mocking for tests

### 4. Isolate-Based Processing

**Planned**: Move ML inference to Dart Isolate
- Prevents UI blocking
- Better performance
- Parallel processing capability

### 5. Caching Layer

**Planned**: Local caching for:
- Recent repair guides
- Recognized parts
- API responses (with TTL)

### 6. Error Recovery

**Planned**:
- Retry logic with exponential backoff
- Offline mode with cached data
- Graceful degradation

### 7. Modular Architecture

**Planned Structure**:
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── theme/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
```

## Performance Considerations

### Current Performance Characteristics

- **Image Processing**: Synchronous (blocks UI thread)
- **ML Inference**: ~30-50ms per frame (device dependent)
- **API Calls**: ~1-3 seconds (network dependent)
- **Memory Usage**: Moderate (camera stream + model)

### Optimization Opportunities

1. **Async Image Processing**: Move to isolate
2. **Model Optimization**: Quantization, pruning
3. **Caching**: Cache API responses
4. **Lazy Loading**: Load model on demand
5. **Image Compression**: Reduce image size before processing

## Security Considerations

### Current Implementation

- API key stored in code (needs improvement)
- No data encryption
- No authentication

### Planned Improvements

- Environment variable-based API key storage
- Secure storage for sensitive data
- API key rotation support
- Input validation and sanitization

## Testing Strategy

### Current State

- Basic widget tests
- Manual testing

### Planned Testing

- **Unit Tests**: Service layer logic
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end flows
- **Mock Services**: For testing without API/ML dependencies

## Conclusion

The current architecture provides a solid foundation for the application. The planned improvements will enhance maintainability, testability, and performance while maintaining the core functionality.

For implementation details, refer to:
- [API Documentation](API_DOCUMENTATION.md)
- [Setup Guide](SETUP.md)
- [Improvements Plan](../improvements.md)

---

**Last Updated**: 2024  
**Architecture Version**: 1.0

