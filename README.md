# Gen-AR Mechanic: AI-Powered Vehicle Repair Assistant (Final Year Project)

Gen-AR Mechanic is our final-year B.Tech project. It is a Flutter-based mobile application that combines computer vision and generative AI to give practical, step-by-step guidance for basic vehicle repair tasks. The goal is not to replace professional tools, but to help students, hobbyists, and entry-level mechanics quickly locate parts and understand what to do next.

## 👥 Team Members

- **Tejas Dhawale** - tejasdhawale145@gmail.com
- **Shivtej Shete** - shivtejshete0827@gmail.com
- **Jay Patil** - jay71patil@gmail.com
- **Sneha Agarwal** - snehaagarwal09f@gmail.com
- **Dr. Suvarna Joshi** (Supervisor) - suvarna.joshi@mituniversity.edu.in

**Institution**: Department of CSE, MIT School of Computing, MIT ADT University, Pune, India

## 📋 Project Overview (Target State for Final Submission)

In the final state of this project (after ~1–2 months of work), Gen-AR Mechanic will:

- Use the phone camera to capture an image of a component in the engine bay.
- Run a lightweight TensorFlow Lite model on-device to recognize a small set of common parts (e.g., battery, radiator, fuse box, AC compressor).
- Send the recognized part name + the user’s question to the Gemini API.
- Show a clear, structured repair guide that is grounded in the detected part and the question.
- Store a simple history of previous guides on the device for quick reference.

We are intentionally keeping the scope realistic for a student project: mobile AR overlays, 5G edge offloading, and full digital twin features from the reference paper are **not** in scope for this semester.

### Planned Final Features (Realistic Scope)

- 📸 **Camera-based Capture**: Capture images of vehicle parts using the device camera.
- 🤖 **On-Device Part Recognition**: TensorFlow Lite model (MobileNetV2-based) to classify a small set of engine components.
- 💬 **AI-Powered Repair Guides**: Integration with Google Gemini API to generate step-by-step repair instructions using the recognized part and user question.
- 🧠 **Basic Safety Guardrails**: Prompting Gemini with clear constraints (no invented torque values, etc.) and simple validation on responses.
- 🕒 **Request Flow UI**: Clear progress indicators for “capturing → recognizing → generating guide”.
- 🧾 **History View**: Local history of recent repair queries and responses (stored using shared_preferences or similar).
- 🌐 **Offline-Friendly Recognition**: Part recognition works offline (model on-device); AI repair guide requires internet.
- 🎨 **Student-Friendly UI**: Material Design 3 UI that is clean and easy to demo, with light/dark mode.

### Technology Stack

- **Framework**: Flutter 3.5.3+
- **ML Framework**: TensorFlow Lite
- **AI Service**: Google Gemini API
- **Language**: Dart
- **Platforms**: Android, iOS

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.5.3 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Google Gemini API Key
- TensorFlow Lite model file (`car_parts.tflite`)
- Labels file (`labels.txt`)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd version-0.9.0-beta-1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Create a `.env` file in the root directory
   - Add your Gemini API key:
     ```
     GEMINI_API_KEY=your_api_key_here
     ```
   - **Note**: The `.env` file should be added to `.gitignore` to prevent committing sensitive keys

4. **Add ML Model Assets**
   - Place your TensorFlow Lite model in `assets/car_parts.tflite`
   - Place your labels file in `assets/labels.txt`
   - Ensure `pubspec.yaml` includes these assets (see Setup Guide)

5. **Run the application**
   ```bash
   flutter run
   ```

For detailed setup instructions, see [SETUP.md](SETUP.md).

## 📁 Project Structure

```
lib/
├── config/
│   └── api_config.dart          # API configuration
├── screens/
│   └── mechanic_home_page.dart  # Main application screen
├── services/
│   ├── gemini_service.dart      # Gemini API integration
│   └── ml_service.dart          # TensorFlow Lite inference
└── widgets/
    ├── camera_view.dart         # Camera preview widget
    └── response_card.dart       # AI response display widget
```

## 🔧 Current Implementation Status

This repository currently contains a **working prototype** plus documentation for the **target final version**.

### ✅ Already Implemented (Prototype)

- Basic Flutter app structure with a single main screen.
- Camera integration with live preview and image capture.
- Service classes for:
  - TensorFlow Lite inference (structure in place).
  - Gemini API integration (basic prompt and network call).
- Simple UI to:
  - Capture an image.
  - Type a question.
  - Show an AI-generated response in a card.
- Basic error messages for camera and network failures.

### 🎯 Target for Final Submission (Next 1–2 Months)

By the time we submit the project, we aim to have:

- A trained and integrated TFLite model for a **small but meaningful** set of engine parts.
- Stable, user-friendly error handling (no cryptic errors, clear messages).
- A simple but proper state management approach (Provider or Riverpod).
- A small history view of previous repair guides.
- Basic caching of the last few AI responses for quick offline access.
- At least a **reasonable test suite** (unit tests for services + a few widget tests).

The detailed roadmap for how we will get there is kept in `docs/PROJECT_STATUS.md` and `improvements.md`.

## 📖 Documentation

- [Setup Guide](docs/SETUP.md) - Detailed installation and configuration instructions
- [Architecture Documentation](docs/ARCHITECTURE.md) - System design and architecture overview
- [API Documentation](docs/API_DOCUMENTATION.md) - Service layer API reference
- [Improvements Plan](improvements.md) - Comprehensive roadmap for enhancements

## 🎯 Usage

1. **Launch the app** and grant camera permissions when prompted
2. **Position the camera** to capture the vehicle part you want to identify
3. **Enter your question** about the part (e.g., "Why is it leaking?")
4. **Tap "Capture & Get Repair Guide"** to process the image
5. **View the results**: The app will display the recognized part and AI-generated repair guide

## ⚠️ Known Limitations

- ML model requires training data and model file (not included in repository)
- API key must be configured manually
- Currently optimized for specific part classes (requires model training)
- Performance may vary based on device capabilities
- Requires active internet connection for AI guidance generation

## 🔒 Security Notes

- **Never commit API keys** to version control
- Use environment variables for sensitive configuration
- The `.env` file is excluded from version control
- API keys should be rotated regularly

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Current test coverage includes basic widget tests. Comprehensive unit and integration tests are planned for future releases.

## 📝 License

This project is developed as part of academic research at MIT ADT University.

## 🤝 Contributing

This is an academic project. For contributions or questions, please contact the team members listed above.

## 📚 References

- [Flutter Documentation](https://docs.flutter.dev/)
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [Google Gemini API](https://ai.google.dev/docs)
- [MobileNetV2 Architecture](https://arxiv.org/abs/1801.04381)

## 📧 Contact

For inquiries about this project, please contact:
- **Project Lead**: Tejas Dhawale (tejasdhawale145@gmail.com)
- **Supervisor**: Dr. Suvarna Joshi (suvarna.joshi@mituniversity.edu.in)

---

**Version**: 0.9.0-beta-1  
**Last Updated**: 2024  
**Status**: Active Development
