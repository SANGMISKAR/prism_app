import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: "", //addd ur API Key from fire base 
      authDomain: "prism-aec3b.firebaseapp.com",
      projectId: "prism-aec3b",
      storageBucket: "prism-aec3b.appspot.com",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "1:994984782954:android:ab370e28f8a97679bf6e13",
    );
  }
}
