from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
from difflib import get_close_matches
from googletrans import Translator
import math

# -------------------------------
# Initialize Flask app
# -------------------------------
app = Flask(__name__)
CORS(app)

# -------------------------------
# Load trained model
# -------------------------------
try:
    model = joblib.load("crop_yield_model.pkl")
    print("✅ Model loaded successfully!")
except Exception as e:
    print("⚠️ Model not loaded:", e)
    model = None

# -------------------------------
# Translator for Tamil to English
# -------------------------------
translator = Translator()

# Known crop synonyms and list
CROP_SYNONYMS = {"paddy": "rice", "corn": "maize", "ground nut": "groundnut"}
crop_list = ["rice", "maize", "wheat", "groundnut"]
crop_encoding = {name: idx for idx, name in enumerate(crop_list)}

# -------------------------------
# Helper functions
# -------------------------------
def tamil_to_english(crop_tamil):
    try:
        english_crop = translator.translate(crop_tamil, src="ta", dest="en").text.lower()
        return english_crop
    except:
        return crop_tamil.lower()

def fix_synonym(english_crop):
    return CROP_SYNONYMS.get(english_crop, english_crop)

def fuzzy_match_crop(english_crop):
    matches = get_close_matches(english_crop, crop_list, n=1, cutoff=0.6)
    return matches[0] if matches else ""

# -------------------------------
# Routes
# -------------------------------
@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "✅ Crop Yield Prediction API is running!"})

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json(force=True)

        if model is None:
            return jsonify({"error": "Model not loaded"}), 500

        # Handle Tamil crop input
        crop_tamil = data.get("Crop_Tamil", "").strip()
        english_crop = tamil_to_english(crop_tamil)
        english_crop = fix_synonym(english_crop)
        final_crop = fuzzy_match_crop(english_crop)

        if final_crop == "":
            return jsonify({"error": f"Unknown crop: {crop_tamil}"}), 400

        crop_code = crop_encoding.get(final_crop, 0)

        # Feature vector (matches Flutter input)
        features = np.array([[ 
            data.get("Year", 2025),
            data.get("District_Encoded", 1),
            crop_code,
            data.get("Season_Encoded", 1),
            data.get("Area", 1.0),
            data.get("Temp", 28.0),
            data.get("Humidity", 60.0),
            data.get("Wind", 2.0),
            200,  # PAR constant
            10,   # SW_DWN constant
            0.5,  # SoilWetness constant
            50    # Rainfall constant
        ]])

        # Predict yield
        prediction_log = model.predict(features)
        prediction = prediction_log[0] if isinstance(prediction_log, (list, np.ndarray)) else prediction_log

        # If model was trained on log(y+1), reverse it
        try:
            prediction = math.exp(prediction) - 1
        except:
            pass

        return jsonify({
            "predicted_yield": round(float(prediction), 2),
            "final_crop_used": final_crop
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------------
# Run Flask app
# -------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
