from flask import Flask, request, jsonify
import requests
import joblib
import numpy as np
from flask_cors import CORS

app = Flask(__name__)
CORS(app)



# Load your trained model
try:
    model = joblib.load("air_quality_model_new.joblib")
    print("✅ Model loaded successfully.")
except Exception as e:
    print("❌ Error loading model:", e)
    model = None

# Replace this with your actual OpenWeather API Key
API_KEY = "f71b6a9ccf235f000d3dd230691016a1"

# Define the order of pollutants expected by the model
POLLUTANT_ORDER = ['co', 'no2', 'o3', 'so2', 'pm25', 'pm10']

def get_pollutant_data(lat, lon):
    """
    Fetch air pollution data from OpenWeather API
    """
    url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={API_KEY}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        components = data['list'][0]['components']
        
        pollutant_values = [components.get(key, 0.0) for key in POLLUTANT_ORDER]
        return pollutant_values
    except Exception as e:
        print("❌ Error fetching pollutant data:", e)
        return None

@app.route("/")
def home():
    return "🌍 Air Quality Prediction API is running."

@app.route("/predict", methods=["POST"])
def predict():
    """
    Expects JSON input:
    {
        "lat": 12.9716,
        "lon": 77.5946
    }
    Returns:
    {
        "status": "Safe" or "Hazardous",
        "data": {
            "co": value, "no": value, ...
        }
    }
    """
    if not model:
        return jsonify({"error": "Model not loaded"}), 500

    try:
        data = request.get_json()
        lat = float(data.get("lat"))
        lon = float(data.get("lon"))

        # Fetch pollutant values
        pollutant_values = get_pollutant_data(lat, lon)
        if pollutant_values is None:
            return jsonify({"error": "Failed to retrieve pollutant data"}), 500

        # Make prediction
        prediction = model.predict([pollutant_values])
        result = "Safe" if prediction[0] == 0 else "Hazardous"

        # Prepare readable pollutant data
        pollutant_dict = dict(zip(POLLUTANT_ORDER, pollutant_values))

        return jsonify({
            "status": result,
            "data": pollutant_dict
        })

    except Exception as e:
        print("❌ Exception in /predict:", e)
        return jsonify({"error": "Invalid request or internal error"}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

