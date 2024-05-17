import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../HomeScreen.dart';
import '../current_page.dart';
import 'contact_screen.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        final User? user = userCredential.user;
        if (user != null) {
          final userExists = await _checkUserExists(user.email.toString());
          if (!userExists) {
            await _createUser(user,googleUser.id);
          }
        }

        String currentUserId = googleUser.id;
        String currentUserName = '';
        String currentUserDocID='';
        try{
        QuerySnapshot querySnapshot = await _firestore.collection("users").where("id", isEqualTo: googleUser.id).get();
        currentUserName = querySnapshot.docs.first.get('name') as String;
        currentUserDocID = querySnapshot.docs.first.id;

        AppState.currentUserDocID=currentUserDocID;
        }catch (error) {
          print('Login failed: $error');
          currentUserName = "Can't display your Name";
        }


        // Navigate to the Contact Screen after successful login
        Navigator.push(
          context,
          // MaterialPageRoute(builder: (context) => ContactScreen(
          //   currentUserId: currentUserId,
          //   currentUserName: currentUserName,
          //   ),
          MaterialPageRoute(builder: (context) => HomeScreen(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            currentUserDocID:currentUserDocID,
          ),
          ),
        );
      }
    } catch (error) {
      print('Login failed: $error');
      // Show an error message or perform other error handling.
    }
  }

  Future<bool> _checkUserExists(String email) async {
    final querySnapshot =
    await _firestore.collection('users').where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _createUser(User user,String id) async {
    final userData = {
      'registration_time': DateTime.now(),
      'email': user.email,
      'id': id,
      'name': user.displayName,
      'photourl': user.photoURL,
      'phone_number': -1,
    };
    await _firestore.collection('users').doc().set(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
      ),
      body: Center(
    child: Container(

      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: ElevatedButton(
        onPressed: () => _handleSignIn(context),
        child: const Text('Sign in with\nGoogle',style: TextStyle(fontSize: 100)),
      ),
    )
      ),
    );
  }
}
