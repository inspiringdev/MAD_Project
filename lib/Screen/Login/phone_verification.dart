import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sawaari/Components/ink_well_custom.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/theme/style.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneVerification extends StatefulWidget {
  final String verificationId;
  final String? phoneNumber; // Optional for Resend OTP

  const PhoneVerification({required this.verificationId, this.phoneNumber, Key? key}) : super(key: key);

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 6; // Changed to 6 to match Firebase OTP length
  bool hasError = false;
  String? errorMessage;
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (controller.text.trim().length != pinLength) {
      setState(() {
        hasError = true;
        errorMessage = 'Please enter a valid $pinLength-digit OTP';
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: controller.text.trim(),
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
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
      setState(() {
        isLoading = false;
        hasError = true;
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
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> resendOTP() async {
    if (widget.phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = 'Error: ${e.message}';
          });
        },
        codeSent: (String newVerificationId, int? resendToken) {
          setState(() {
            isLoading = false;
            hasError = false;
            errorMessage = 'OTP resent successfully';
          });
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {},
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: blackColor),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoute.loginScreen),
        ),
      ),
      body: SingleChildScrollView(
        child: InkWellCustom(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 0.0, 20, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
                  child: Text('Phone Verification', style: heading35Black),
                ),
                Container(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Text('Enter your OTP code here'), // Fixed typo: 'hear' to 'here'
                ),
                if (hasError && errorMessage != null)
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (!hasError && errorMessage != null)
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                Center(
                  child: PinCodeTextField(
                    appContext: context,
                    length: pinLength,
                    controller: controller,
                    obscureText: false,
                    obscuringCharacter: '*',
                    animationType: AnimationType.scale,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      inactiveColor: blackColor,
                      activeColor: primaryColor,
                      selectedColor: secondaryColor,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    onChanged: (text) {
                      setState(() {
                        thisText = text;
                        hasError = false;
                        errorMessage = null;
                      });
                    },
                    onCompleted: (text) {
                      print("DONE $text");
                      verifyOTP(); // Auto-verify on completion
                    },
                    enableActiveFill: false,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width - 50,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : TextButton(
                    child: Text('VERIFY NOW', style: headingWhite),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    onPressed: verifyOTP,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: resendOTP,
                        child: Text(
                          "I didn't get a code",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}