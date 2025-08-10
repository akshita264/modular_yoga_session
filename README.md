# Modular Yoga Session App

A Flutter app that plays modular yoga sessions with synced audio, images, and instructions. This app reads session data from a JSON file, displaying poses, playing corresponding audio, and showing synchronized text/image cues.

---

## Features

- Loads yoga session metadata, assets, and sequence data from a JSON file.
- Plays audio segments with proper looping (e.g., breathing cycles).
- Displays synchronized instructional text and images based on audio playback position.
- Tracks user session streaks using persistent storage.
- Clean UI with progress indicators, play/pause, and restart controls.
- Automatically handles loop counts and session flow.

---

## Project Structure

- **models/**: Dart classes representing the JSON structure (`Session`, `Metadata`, `Sequence`, `ScriptEntry`, etc.).
- **assets/poses/**: JSON session files describing yoga sequences.
- **assets/images/**: Pose images referenced in the JSON.
- **assets/audio/**: Audio files referenced in the JSON.
- **lib/main.dart**: Main app source code with JSON loading, UI, and audio playback logic.

---

## How It Works

1. **JSON Session**:  
   Defines metadata, audio/image assets, and sequences including loops with iteration counts.
   
2. **SessionLoader**:  
   Loads and parses the JSON, replaces placeholders (like `{{loopCount}}`) with actual values.
   
3. **Preview Page**:  
   Shows the list of yoga sequences with images and durations. User can start the session from here.
   
4. **Yoga Player Page**:  
   Plays the audio and updates the UI with synced text and images. Handles loop logic and session progress.
   
5. **Session Completion**:  
   Shows a completion screen and saves streak info.

---

## Setup Instructions

### 1. Clone or Download the Project

```bash
git clone <repository-url>
cd modular-yoga-session
```
### 2.  Add Assets
Place your assets as follows:

JSON session file:
assets/poses/CatCowJson.json

Images:
assets/images/Base.png, assets/images/Cat.png, assets/images/Cow.png (as per your JSON)

Audio:
assets/audio/cat_cow_intro.mp3, assets/audio/cat_cow_loop.mp3, assets/audio/cat_cow_outro.mp3

### 3. Update pubspec.yaml
Add the assets section:
flutter:
  assets:
    - assets/poses/CatCowJson.json
    - assets/images/Base.png
    - assets/images/Cat.png
    - assets/images/Cow.png
    - assets/audio/cat_cow_intro.mp3
    - assets/audio/cat_cow_loop.mp3
    - assets/audio/cat_cow_outro.mp3

### 4.  Install Dependencies
```bash
flutter pub get
```
### How to Run 
```bash
flutter run
```
The app starts at the preview screen showing the yoga session. Tap Start Session to begin playing the guided yoga flow with synced images and instructions.

Notes
The app relies on accurate timings in the JSON to sync text and images with audio.

Loop sequences will repeat exactly as many times as defined by defaultLoopCount in metadata.

If audio or images are missing, placeholders or error messages will appear.

Streak tracking saves your daily session completion history using SharedPreferences.

Troubleshooting
- Audio/Visual Not Syncing:
Ensure your audio file durations match the durationSec and script start/end times in the JSON.

- Assets Not Found:
Verify file paths and names match exactly (case-sensitive).

- Playback Issues:
Restart the app or test on a physical device/emulator with audio support.

- Customization
To add new yoga sessions, create new JSON files in assets/poses/ following the existing JSON format.

Add corresponding images and audio files to assets/images/ and assets/audio/.

Update the app logic if needed to support new features or UI changes.

- Dependencies
- Flutter SDK
- audioplayers
- shared_preferences
