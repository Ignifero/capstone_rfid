import pyrebase

config = {
  "apiKey": 'AIzaSyAWVsYA-_yiJL5B7x0uAkXcpoXuM3jwFTU',
  "authDomain": 'nfc-scanner-316c4.firebaseapp.com',
  "projectId": 'nfc-scanner-316c4',
  "storageBucket": 'nfc-scanner-316c4.appspot.com',
  "messagingSenderId": '1065241435557',
  "appId": '1:1065241435557:web:fb6be93cc71a173421dc4c',
  "databaseURL": ""
}

firebase = pyrebase.initialize_app(config)
auth = firebase.auth()