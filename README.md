
# ZooCare Task Manager
ZooCare is a Flutter-based application that allows zookeepers to manage animals and assign care tasks (such as feeding, cleaning, etc.). The app supports both local and remote storage backends and allows switching between them at runtime.

## Features
- Add and remove animals
- Add and check off care tasks for each animal
- Switch between local SQLite database and a Flask-based REST API
- Works on desktop and mobile devices

## Technologies Used
- Flutter
- SQLite (via `sqflite_common_ffi`)
- REST API (Flask + local JSON file storage)
- Python 3

## Project Structure
```
lib/
├── main.dart               # App entry point and tab navigation
├── detail_page.dart        # Displays and manages animal tasks
└── services/
    ├── database_util.dart  # SQLite database logic
    └── api_util.dart       # API request logic
```

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/MauroDeceuninck/pet_zoo_manager.git
cd pet_zoo_manager
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the application
```bash
flutter run
```

## Using the Flask API

### Requirements
* Python 3
* Flask installed (`pip install flask`)

### Run the backend
```bash
python server.py
```

Make sure to update `baseUrl` in `lib/services/api_util.dart`:
```dart
static const String baseUrl = 'http://<your-ip>:8080';
```

For Android emulators, use:

```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

## Switching Between Local and API Mode
1. Tap on the **Settings** tab
2. Use the toggle to switch between "Local" and "API" mode
3. All data operations (CRUD) will use the selected mode

## Sample Data Format

**animals.json**:
```json
[
  {
    "id": "abc123",
    "name": "Leo",
    "species": "Lion"
  }
]
```

**tasks.json**:
```json
[
  {
    "id": "task001",
    "animal_id": "abc123",
    "description": "Feed meat",
    "done": 0
  }
]
```
