# Project Status

This document tracks the **current status** and the **target final state for our semester project**. It is meant as a realistic checklist for what we (as students) can finish in about 1–2 months.

## Current Version: 0.9.0-beta-1

**Last Updated**: 2024

## Implementation Status (High-Level)

### ✅ Already Done (Prototype)

#### Core Functionality
- [x] Flutter application structure
- [x] Camera integration with live preview
- [x] Image capture functionality
- [x] TensorFlow Lite service **skeleton** (no final trained model yet)
- [x] Gemini API service integration (basic prompt + network call)
- [x] Basic UI for part capture + question + response
- [x] Basic error handling for camera and API calls

#### Documentation
- [x] README with project overview
- [x] Setup guide (SETUP.md)
- [x] Architecture documentation (ARCHITECTURE.md)
- [x] API documentation (API_DOCUMENTATION.md)
- [x] Improvements roadmap (improvements.md)

#### Project Structure
- [x] Organized code structure (screens, services, widgets, config)
- [x] Android platform configuration
- [x] iOS platform configuration
- [x] Basic asset structure

### 🎯 Target Final Features (Within 1–2 Months)

#### Core Functionality (Must-Haves)
- [ ] Working TFLite model integrated for a **small set of classes** (e.g., battery, radiator, fuse box, AC compressor).
- [ ] Stable end-to-end flow: capture → recognize part → call Gemini → show guide.
- [ ] Camera and storage permissions handled properly on Android (and iOS if time allows).
- [ ] Clear user-facing error messages (no raw exception strings).

### 📋 Planned Features

#### Quality & Architecture (Should-Haves)
- [ ] Add missing dependencies (`tflite_flutter`, `image`, `flutter_dotenv`, etc.).
- [ ] Secure API key management using `.env` (no hardcoded keys in repo).
- [ ] Clean ML service implementation (correct tensor handling, no crashes).
- [ ] Clean Gemini service implementation (clear error messages, timeouts).
- [ ] Basic state management using Provider/Riverpod instead of only `setState`.
- [ ] Simple repository or manager class to orchestrate ML + Gemini + history.

#### UI/UX (Nice but Realistic)
- [ ] Progress indicator showing what step we are in (capture / recognize / generate).
- [ ] Image preview with option to retake before sending to ML.
- [ ] Dark mode theme.
- [ ] Slightly polished response card (headings, bullet points, etc.).
- [ ] A basic history screen listing recent repair queries and guides.

#### Testing & Stability
- [ ] Unit tests for MLService (with mocks / fake data).
- [ ] Unit tests for GeminiService (mocked HTTP client).
- [ ] A few widget tests for the main screen.
- [ ] Manual testing on at least 2–3 Android devices.

## Technical Debt (What We Know We Need to Fix)

### High Priority
1. **API Key Security**: Currently placeholder-based; must move fully to `.env` + `flutter_dotenv`.
2. **Missing Dependencies**: `tflite_flutter`, `image`, and others must be properly added and locked in `pubspec.yaml`.
3. **Error Handling**: Responses should be user-friendly; right now some errors are just raw strings.
4. **State Management**: Too much manual `setState`; introduce at least a basic Provider structure.

### Medium Priority
1. **Code Organization**: Move towards a slightly cleaner separation (core, services, UI) without over-engineering.
2. **Testing**: Very few automated tests at the moment.
3. **Comments & Docs**: Some functions still lack clear comments.
4. **Performance**: ML runs on main isolate; may cause jank on low-end phones.

### Low Priority
1. **Fonts & Assets**: Clean up Inter font reference or add the actual font files.
2. **Logging**: Replace raw `print()` calls with a simple logger helper.
3. **Polish**: Extra animations and micro-interactions (only if time remains).

## Known Issues

### Critical
- None currently identified (pending testing with actual model and API key)

### High Priority
- ML model file not included (requires training/obtaining model)
- API key not configured (requires user setup)
- Camera permissions not declared in AndroidManifest.xml

### Medium Priority
- No offline mode (requires internet for AI guidance)
- No caching mechanism
- Performance may degrade on lower-end devices

### Low Priority
- UI could be more polished
- Missing animations and transitions
- No dark mode support

## Dependencies Status

### Required (Currently Missing)
- `tflite_flutter`: ^0.10.4 - For TensorFlow Lite inference
- `image`: ^4.1.3 - For image processing
- `flutter_dotenv`: ^5.1.0 - For environment variable management

### Required (Currently Included)
- `flutter`: SDK
- `http`: ^1.2.0 - For API calls
- `camera`: ^0.11.0+2 - For camera access
- `path_provider`: ^2.1.2 - For file system access
- `cupertino_icons`: ^1.0.8 - For iOS icons

### Planned (Future)
- `provider`: ^6.1.1 - For state management
- `shared_preferences`: ^2.2.2 - For local storage
- `connectivity_plus`: ^5.0.2 - For network checking
- `permission_handler`: ^11.1.0 - For permission management
- `get_it`: ^7.6.4 - For dependency injection
- `flutter_markdown`: ^0.6.18 - For markdown rendering

## Testing Status

### Current Coverage
- Basic widget test (template, needs update)
- Manual testing

### Planned Coverage
- Unit tests: 0% (target: 80%+)
- Widget tests: <5% (target: 60%+)
- Integration tests: 0% (target: 50%+)

## Documentation Status

### Completed
- ✅ README.md - Project overview and quick start
- ✅ docs/SETUP.md - Detailed setup instructions
- ✅ docs/ARCHITECTURE.md - System architecture
- ✅ docs/API_DOCUMENTATION.md - Service API reference
- ✅ improvements.md - Comprehensive improvement plan

### Planned
- [ ] Code comments and documentation
- [ ] User guide
- [ ] Developer guide
- [ ] Deployment guide
- [ ] Troubleshooting guide

## Performance Metrics

### Current (Estimated)
- App startup: ~2-3 seconds
- Image capture: <1 second
- ML inference: ~30-50ms (device dependent)
- API call: ~1-3 seconds (network dependent)
- Total workflow: ~3-5 seconds

### Target
- App startup: <2 seconds
- Image capture: <500ms
- ML inference: <30ms
- API call: <2 seconds
- Total workflow: <3 seconds

## Next Steps

### Immediate (This Week)
1. Add missing dependencies to pubspec.yaml
2. Fix critical bugs (API URL, tensor buffer)
3. Add camera permissions
4. Implement secure API key management

### Short Term (Next 2 Weeks)
1. Implement proper error handling
2. Add state management
3. Improve UI/UX
4. Add basic testing

### Medium Term (Next Month)
1. Complete architecture refactoring
2. Add advanced features (history, caching)
3. Comprehensive testing
4. Performance optimization

### Long Term (Future)
1. AR overlay implementation
2. Advanced ML features
3. Multi-language support
4. Cloud integration enhancements

## Risk Assessment

### High Risk
- **ML Model Availability**: Requires trained model or access to training data
- **API Costs**: Gemini API usage may incur costs at scale
- **Device Compatibility**: Performance varies significantly across devices

### Medium Risk
- **Thermal Throttling**: Extended use may cause device heating (as mentioned in research paper)
- **Network Dependency**: Requires stable internet for AI guidance
- **Model Accuracy**: Depends on training data quality

### Low Risk
- **Platform Support**: Flutter provides good cross-platform support
- **Maintenance**: Well-documented codebase should be maintainable

## Success Criteria

### MVP (Already Close)
- [x] Camera integration working.
- [ ] ML model recognition working end-to-end.
- [ ] AI guidance generation working in the app (not just via curl/Postman).
- [ ] Basic error handling (no hard crashes in normal flow).
- [ ] One complete demo flow from capture to guide.

### Final Semester Submission (Target)
- [ ] MVP fully working with at least 3–4 real part classes.
- [ ] Clean, demo-able UI (no obvious “prototype” glitches).
- [ ] Reasonable error handling and input validation.
- [ ] At least a handful of unit + widget tests.
- [ ] Documentation updated to match what is actually implemented.

---

**Status**: Active Development  
**Next Review**: Weekly  
**Maintained by**: Gen-AR Mechanic Development Team

