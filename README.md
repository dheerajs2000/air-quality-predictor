# 🌍 Air Quality Predictor Web App

A full-stack web application that predicts the air quality at a user's current location using real-time data from the OpenWeatherMap API and a trained machine learning model.

Built with **Flutter Web (Frontend)** and **Flask + Python (Backend)**. Deployed using **Docker** and **Google Cloud Run** for scalable access from anywhere.

---

## 🚀 Features

- 📍 Gets user’s geolocation in real time
- 🌫 Fetches air pollutant levels from OpenWeatherMap API
- 🧠 Predicts air quality status using a trained Random Forest model
- 📈 Displays "Safe" or "Hazardous" status with pollutant data
- ☁️ Dockerized and deployed on Google Cloud Run

---

## 🛠️ Tech Stack

### ✅ Frontend
- Flutter Web
- `http` for API calls
- `dart:html` for geolocation
- Google Fonts for styling

### ✅ Backend
- Python 3.x
- Flask + Flask-CORS
- Scikit-learn + Joblib (for model inference)
- Requests (for API calls to OpenWeatherMap)

### ✅ Deployment
- Docker for containerization
- Google Artifact Registry
- Google Cloud Run (public URLs for both services)

---

## 📂 Folder Structure

MajorProject/
├── backend/                  # Flask backend + ML model
│   ├── app.py
│   ├── air_quality_model.joblib
│   └── Dockerfile
│
├── air_quality_web/          # Flutter web frontend
│   ├── lib/
│   ├── web/
│   └── Dockerfile
│
├── docker-compose.yml        # For local Docker development
└── README.md                 # ← You are here


---

## 🧪 Local Development

### 1. Run Backend (Flask)

cd backend
python app.py

### 2. Run Frontend (Flutter Web)

cd air_quality_web
flutter build web
cd build/web
python3 -m http.server 8080

OR Use Docker Compose

docker-compose up --build


🚢 Deployment on Google Cloud Run
1.Dockerize both frontend and backend:

Flutter web: build and serve with nginx or http-server

Flask backend: expose PORT=8080

2.Push both Docker images to Artifact Registry:

docker tag <image_name> asia-south1-docker.pkg.dev/<PROJECT-ID>/<REPO>/frontend
docker push asia-south1-docker.pkg.dev/<PROJECT-ID>/<REPO>/frontend

3.Deploy on Cloud Run from image and allow unauthenticated access.

4.Replace backend URL in main.dart with the actual deployed Cloud Run backend URL.


🧠 ML Model
Model: RandomForestClassifier

Trained on: Real-time pollutant concentration data

Input: ['co', 'no2', 'o3', 'so2', 'pm25', 'pm10']

Output: Safe or Hazardous
