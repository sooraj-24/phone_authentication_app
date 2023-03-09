import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_authentication_app/processing/constants.dart';
import 'package:phone_authentication_app/Screens/otp.dart';
import 'package:sms_autofill/sms_autofill.dart';

class PhoneNumberScreen extends StatefulWidget {
  static String phoneNumber = '';
  static String verify = '';
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  TextEditingController countryController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool error = false;
  String errorText = '';

  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+91";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: kYellow,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify your \n Phone number',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'We will send you a One Time Password on this mobile number.',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Enter Phone number:',
                            style: TextStyle(
                              fontSize: 15
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: 35,
                                child: TextField(
                                  controller: countryController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Text(
                                "|",
                                style: TextStyle(fontSize: 33, color: Colors.grey),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Form(
                                    key: formKey,
                                    child: TextFormField(
                                      onSaved: (value){
                                        PhoneNumberScreen.phoneNumber = value!;
                                      },
                                      validator: (value){
                                        if(value == ''){
                                          setState(() {
                                            error = true;
                                            errorText = 'Enter your phone number';
                                          });
                                        } else if (value!=null && value.length < 10){
                                          setState(() {
                                            error = true;
                                            errorText = 'Enter a valid phone number';
                                          });
                                        } else {
                                          setState(() {
                                            error = false;
                                            errorText = '';
                                          });
                                        }
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Phone",
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: error
                              ? Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 14),
                            child: Text(
                              errorText,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                              : null,
                        ),
                        Expanded(child: Container()),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final isValid =formKey.currentState?.validate();
                              if(!error){
                                formKey.currentState?.save();
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return OtpScreen();
                                }));
                                var appSignature = await SmsAutoFill().getAppSignature;
                                await FirebaseAuth.instance.verifyPhoneNumber(
                                  phoneNumber: '${countryController.text+PhoneNumberScreen.phoneNumber}',
                                  verificationCompleted: (PhoneAuthCredential credential) {},
                                  verificationFailed: (FirebaseAuthException e) {},
                                  codeSent: (String verificationId, int? resendToken) {
                                    PhoneNumberScreen.verify = verificationId;
                                  },
                                  codeAutoRetrievalTimeout: (String verificationId) {},
                                );
                                print('app signature ${appSignature}');
                              }
                            },
                            child: Ink(
                              height: 50,
                              decoration: BoxDecoration(
                                color: kBlue,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Center(
                                child: Text(
                                  'Send OTP',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
