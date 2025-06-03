import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/theme/style.dart';

class PhoneVerification extends StatefulWidget {
  final String verificationId;

  const PhoneVerification({required this.verificationId, Key? key}) : super(key: key);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (user.metadata.creationTime == user.metadata.lastSignInTime) {
          // New user, navigate to profile setup
          Navigator.of(context).pushReplacementNamed(AppRoute.profileScreen);
        } else {
          // Existing user, navigate to home
          Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The verification code is invalid.';
          break;
        case 'session-expired':
          errorMessage = 'The verification session has expired.';
          break;
        case 'quota-exceeded':
          errorMessage = 'SMS quota exceeded. Try again later.';
          break;
        default:
          errorMessage = 'Invalid OTP: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
        backgroundColor: Color(0xFFFDD148),
      ),
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Verification Code',
              style: heading35Black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'We have sent a verification code to your phone number',
              style: textGrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, letterSpacing: 2),
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50.0,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                onPressed: verifyOTP,
                child: Text(
                  'VERIFY',
                  style: headingWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}