import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sawaari/Components/ink_well_custom.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/theme/style.dart';
import 'package:sawaari/Components/validations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool autovalidate = false;
  bool isLoading = false;
  String? _verificationId;
  String? phoneNumber;
  Validations validations = Validations();

  Future<void> submit() async {
    final FormState? form = formKey.currentState;
    if (!form!.validate()) {
      setState(() => autovalidate = true);
    } else {
      form.save();

      // Null safety check
      if (phoneNumber == null || phoneNumber!.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone number is required')),
        );
        return;
      }

      setState(() => isLoading = true);

      // Format phone number to E.164 format for Pakistan
      if (!phoneNumber!.startsWith('+92')) {
        phoneNumber = '+92$phoneNumber'; // Prepend Pakistan country code
      }

      try {
        // Verify phone number
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto verification successful, sign in directly
            try {
              await _auth.signInWithCredential(credential);
              setState(() => isLoading = false);
              // Navigate directly to home screen since verification is complete
              Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
            } catch (e) {
              setState(() => isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Auto sign-in failed: ${e.toString()}')),
              );
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => isLoading = false);
            String errorMessage;
            switch (e.code) {
              case 'invalid-phone-number':
                errorMessage = 'The phone number format is invalid.';
                break;
              case 'too-many-requests':
                errorMessage = 'Too many requests. Please try again later.';
                break;
              case 'quota-exceeded':
                errorMessage = 'SMS quota exceeded. Please try again later.';
                break;
              default:
                errorMessage = 'Error: ${e.message}';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              isLoading = false;
            });
            Navigator.of(context).pushReplacementNamed(
              AppRoute.phoneVerificationScreen,
              arguments: verificationId,
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: Duration(seconds: 60),
        );
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: InkWellCustom(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(children: <Widget>[
                  Container(
                    height: 250.0,
                    width: double.infinity,
                    color: Color(0xFFFDD148),
                  ),
                  Positioned(
                    top: 50.0,
                    right: 100.0,
                    child: Container(
                      height: 400.0,
                      width: 400.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200.0),
                        color: Color(0xFFFEE16D),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    left: 150.0,
                    child: Container(
                      height: 300.0,
                      width: 300.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150.0),
                          color: Color(0xFFFEE16D).withOpacity(0.5)),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(32.0, 150.0, 32.0, 0.0),
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Material(
                                    borderRadius: BorderRadius.circular(7.0),
                                    elevation: 5.0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 20.0,
                                      height: MediaQuery.of(context).size.height * 0.4,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20.0)),
                                      child: Form(
                                          key: formKey,
                                          autovalidateMode: autovalidate
                                              ? AutovalidateMode.always
                                              : AutovalidateMode.disabled,
                                          child: Container(
                                            padding: EdgeInsets.all(32.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Login', style: heading35Black),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    TextFormField(
                                                        keyboardType: TextInputType.phone,
                                                        validator: validations.validateMobile,
                                                        onSaved: (value) => phoneNumber = value,
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                            prefixIcon: Icon(Icons.phone,
                                                                color: Color(getColorHexFromStr('#FEDF62')),
                                                                size: 20.0),
                                                            contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                                            hintText: 'Phone (10 digits)',
                                                            hintStyle: TextStyle(
                                                                color: Colors.grey,
                                                                fontFamily: 'Quicksand')
                                                        )
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: 50.0,
                                                  child: isLoading
                                                      ? Center(child: CircularProgressIndicator())
                                                      : TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.blue,
                                                    ),
                                                    child: Text('NEXT', style: headingWhite),
                                                    onPressed: submit,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ),
                                    )
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Create account? ", style: textGrey),
                                      InkWell(
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(AppRoute.signUpScreen),
                                        child: Text("Sign Up", style: textStyleActive),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          )
                      )
                  ),
                ])
              ]
          ),
        ),
      ),
    );
  }
}