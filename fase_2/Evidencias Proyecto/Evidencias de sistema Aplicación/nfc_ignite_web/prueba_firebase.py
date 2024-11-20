import pyrebase

config = {
  "apiKey": "AIzaSyDIIQ73ZI2rJh1vOHeblrAZqkU2GHoFV50",
  "authDomain": "ignis-a2956.firebaseapp.com",
  "projectId": "ignis-a2956",
  "storageBucket": "ignis-a2956.firebasestorage.app",
  "messagingSenderId": "1089434384807",
  "appId": "1:1089434384807:web:9430756ba5eda03d731e82",
  "measurementId": "G-9N06YMYJ4X",
  "databaseURL": ""
}

firebase = pyrebase.initialize_app(config)
auth = firebase.auth()