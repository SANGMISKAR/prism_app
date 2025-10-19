# 🌈 Prism – AI Image Colorization App

> “✨ Transform the past into vivid memories ✨”

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/FastAPI-Backend-success?logo=fastapi&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-Frontend-blue?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Auth-orange?logo=firebase&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?logo=open-source-initiative&logoColor=white" />
  <img src="https://img.shields.io/badge/Status-Local%20Development-yellow?logo=github" />
</p>

---

## 🧠 Overview

**Prism** is an AI-powered image colorization project that transforms old or black-and-white photos into vibrant, realistic images.  
It uses a **FastAPI backend** for processing and a **Flutter frontend** for uploading, editing, and downloading images.  
The app features a modern, minimal black-and-white aesthetic and Firebase authentication.

---

## 🖥️ Project Architecture

```
Prism/
│
├── Prism_api/                     # FastAPI Backend Folder
│   ├── app.py                 # Main API Script
│   ├── script.py              # AI Colorization Logic
│   ├── colorization_deploy_v2.prototxt
│   ├── colorization_release_v2.caffemodel
│   ├── pts_in_hull.npy
│   └── static/                # Output folder for colorized images
│
└── prism_app/                 # Flutter Application
    ├── lib/
    │   ├── main.dart
    │   ├── auth_screen.dart
    │   ├── home_screen.dart
    │   ├── prism_magic_screen.dart
    │   ├── edit_image_screen.dart
    │   ├── result_screen.dart
    │   └── profile_screen.dart
    └── pubspec.yaml
```

---

## 🧩 Tech Stack

| Layer | Technology |
|--------|-------------|
| Backend | FastAPI (Python 3.11) |
| Frontend | Flutter |
| AI Model | OpenCV Caffe-based Colorization Model |
| Authentication | Firebase Auth |
| Hosting | Localhost (Render planned) |
| Storage | Firebase (user data), Local static folder (images) |

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/SANGMISKAR/prism_api.git
git clone https://github.com/SANGMISKAR/prism_app.git
cd magic
```

---

### 2. Backend Setup (FastAPI)

#### Create Virtual Environment
```bash
python -m venv venv
venv\Scripts\activate   # Windows
source venv/bin/activate  # Mac/Linux
```

#### Install Dependencies
```bash
pip install -r requirements.txt
```

#### Run API Server
```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```

✅ API is now running locally at: `http://127.0.0.1:8000`

---

### 3. Frontend Setup (Flutter App)

#### Open Flutter Project
Open `prism_app` in VS Code or Android Studio.

#### Get Dependencies
```bash
flutter pub get
```

#### Update API URL
In `prism_magic_screen.dart`, replace with your local IP:
```dart
final uri = Uri.parse("http://192.168.1.xxx:8000/upload");
```

#### Run the App
```bash
flutter run
```
The app will launch on your emulator or connected device.

---

## 🧠 How the App Works

1. Upload a black-and-white image.  
2. The image is sent to the local FastAPI server.  
3. AI colorization is applied.  
4. Result is displayed in the app with download option.

---

## 🖼️ Screenshots

> Add actual screenshots in `/screenshots/` folder in your repo.

| Screen | Description | Screenshot |
|---------|--------------|-------------|
|🔐 Sign Up / Sign In | User authentication page with toggle between Sign Up and Sign In | ![Auth Screen](./screenshot/auth_screen.png) |
| 🏠 Home Screen | Main dashboard with “Prism Magic” and “Edit Image” | ![Home Screen](./screenshot/home_screen.png) |
| 🪄 Prism Magic Screen | Upload and start AI colorization | ![Prism Magic](./screenshot/prism_magic_screen.png) |
| 🎨 Result Screen | Displays colorized image with download | ![Result Screen](./screenshot/result_screen.png) |
| 👤 Profile Screen | View and edit user info and avatar | ![Profile Screen](./screenshot/profile_screen.png) |

---

## 🔗 API Endpoint

| Endpoint | Method | Description |
|-----------|---------|-------------|
| /upload | POST | Upload image and get colorized result |

#### Example cURL
```bash
curl -X POST "http://127.0.0.1:8000/upload" \
     -F "file=@image.jpg"
```

#### Response
```json
{
  "colorized_image_url": "http://127.0.0.1:8000/static/colorized_image.png"
}
```

---

## 💾 Output Example

- Saved at: `magic/static/colorized_image.png`  
- Displayed in Flutter app via API response.

---

## 🧑‍💻 Developer

**👤 Sanket Sangmiskar**  
💻 Full Stack Developer | AI & Cloud Enthusiast  
📂 GitHub: [@SANGMISKAR](https://github.com/SANGMISKAR)

---

## 📅 Project Status

| Feature | Status |
|----------|--------|
| FastAPI Backend | ✅ Running locally |
| Flutter Frontend | ✅ Working |
| Firebase Auth | ✅ Integrated |
| Render Deployment | ⏳ Planned |
| Offline AI Model | ⏳ In Progress |

---

## 🧾 License

MIT License – Free to use, modify, and distribute.

---

## ⭐ Contributing

Contributions, issues, and feature requests are welcome!  
Open a Pull Request or raise an Issue.

---

## 🪄 “Transform the Past into Vivid Memories.”

---
## 🌟 Support
If you like this project, please consider giving it a **⭐ on GitHub** — it helps others discover Prism!

