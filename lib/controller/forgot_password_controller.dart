import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:model_bottom/controller/base_controller.dart';
import 'package:model_bottom/screen/home_screen/home_screen.dart';

class ForgotPasswordController extends BaseController{
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool otpVisibility = false.obs;
  User? user;
  RxString verificationID = "".obs;
  RxString text = ''.obs;
  RxString email = "".obs;
  RxBool isForgot = false.obs;
  RxBool isPhone = false.obs;


  @override
  void onInit() {
    super.onInit();
    isForgot.value = Get.arguments["isForgot"];
    isPhone.value = Get.arguments["isPhone"];
    print("isForgot value : ${isForgot.value}");
    print("isPhone value : ${isPhone.value}");
  }

  /*void loginWithPhone() async {

    print("success");
    loader.value = true;
    CircularProgressIndicator();
    await FirebaseAuth.instance

        .verifyPhoneNumber(
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
          phoneController.value.text;
        },

        verificationFailed: (FirebaseAuthException error) {
      print(error.message);},
        codeSent: (String verificationId, int? forceResendingToken) {null;
        }, codeAutoRetrievalTimeout: (String verificationId) {
       null;
    },
    );

    loader.value = false;
    //}
  }*/

  // void sendOTP(String phoneNumber, PhoneCodeSent codeSent,
  //     PhoneVerificationFailed verificationFailed) {
  //   if (!phoneNumber.contains('+')) phoneNumber = '+91' + phoneNumber;
  //   FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       timeout: Duration(seconds: 30),
  //       verificationCompleted: (phoneAuthCredential) {
  //
  //       },
  //       verificationFailed: verificationFailed,
  //       codeSent: codeSent,
  //       codeAutoRetrievalTimeout: (verificationId) {
  //
  //       });   },

  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility.value = true;
        verificationID = verificationId as RxString;
        update();
        // setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID.value, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then(
          (value) {
        // setState(() {
          user = FirebaseAuth.instance.currentUser;
       // });
      },
    ).whenComplete(
          () {
        if (user != null) {
          Fluttertoast.showToast(
            msg: "You are logged in successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Get.to(HomeScreen.pageId);

        } else {
          Fluttertoast.showToast(
            msg: "your login is failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
    );
  }
}