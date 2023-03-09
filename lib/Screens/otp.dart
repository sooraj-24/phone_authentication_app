import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:phone_authentication_app/processing/constants.dart';
import 'package:pinput/pinput.dart';
import 'package:phone_authentication_app/Screens/phone_no.dart';
import 'package:phone_authentication_app/Screens/home.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:telephony/telephony.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String otp = '';
  String otpCode = '';
  bool error = false;
  Telephony telephony = Telephony.instance;
  OtpFieldController otpbox = OtpFieldController();

  @override
  void initState() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address); //+977981******67, sender nubmer
        print(message.body); //Your OTP code is 34567
        print(message.date); //1659690242000, timestamp

        String sms = message.body.toString(); //get the message

        if(message.address == "+977981******67"){
          //verify SMS is sent for OTP with sender number
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'),'');
          //prase code from the OTP sms
          otpbox.set(otpcode.split(""));
          //split otp code to list of number
          //and populate to otb boxes

          setState(() {
            //refresh UI
          });

        }else{
          print("Normal message.");
        }
      },
      listenInBackground: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    //print("Unregistered Listener");
    super.dispose();
  }

  void _listenOtp() async {
    await SmsAutoFill().listenForCode();
    //print("OTP Listen is called");
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
                    padding: const EdgeInsets.only(left: 30,right: 30,bottom: 30,top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(child: Container()),
                        Text(
                          'OTP verification',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Enter the code from the sms we sent to ${PhoneNumberScreen.phoneNumber}',
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
                            'Enter OTP:',
                            style: TextStyle(
                                fontSize: 15
                            ),
                          ),
                        ),
                        // Pinput(
                        //   length: 6,
                        //   showCursor: true,
                        //   onChanged: (value){
                        //     otp = value;
                        //   },
                        // ),
                        // OtpTextField(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   numberOfFields: 6,
                        //   fillColor: Colors.white24,
                        //   filled: true,
                        //   showFieldAsBox: true,
                        //   focusedBorderColor: kBlue,
                        //   onSubmit: (value){
                        //     otp = value;
                        //   },
                        // ),
                        PinFieldAutoFill(
                          currentCode: otpCode,
                          decoration: BoxLooseDecoration(
                              radius: Radius.circular(10),
                              strokeColorBuilder: FixedColorBuilder(
                                  kBlue)),
                          codeLength: 6,
                          onCodeChanged: (code) {
                            print("OnCodeChanged : $code");
                            otpCode = code.toString();
                          },
                          onCodeSubmitted: (val) {
                            print("OnCodeSubmitted : $val");
                          },
                        ),

                        Container(
                          alignment: Alignment.topLeft,
                          child: error
                              ? Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 14),
                            child: Text(
                              'Invalid OTP',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                              : null,
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Text(
                                  'Edit Phone number?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                if(otpCode!=null && otpCode.length < 6){
                                  error = true;
                                } else {
                                  error = false;
                                }
                              });
                              try{
                                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: PhoneNumberScreen.verify, smsCode: otpCode);
                                await auth.signInWithCredential(credential);
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return Home();
                                }));
                              } catch (e){
                                setState(() {
                                  error = true;
                                });
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
                                  'Submit',
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
