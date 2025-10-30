import requests

# Replace with your backend IP or localhost if running locally
url = "http://10.161.80.130:5000/predict"

# Example input (Tamil crop)
data = {
    "Year": 2025,
    "District_Encoded": 3,
    "Crop_Tamil": "நெல்",  # Tamil for "rice"
    "Season_Encoded": 2,
    "Area": 1.5,
    "Temp": 28.5,
    "Humidity": 65,
    "Wind": 3.5,
    "PAR": 200,
    "SW_DWN": 10,
    "SoilWetness": 0.5,
    "Rainfall": 50
}

try:
    response = requests.post(url, json=data)
    print("✅ Status Code:", response.status_code)
    print("✅ Server Response:", response.json())
except Exception as e:
    print("❌ Error contacting server:", e)
