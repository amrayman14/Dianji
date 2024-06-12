import 'dart:convert';

import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/auth/sign_up_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../network/rest_apis.dart';
import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../dashboard/dashboard_screen.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({Key? key}) : super(key: key);

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();

  Country selectedCountry = defaultCountry();

  String otpCode = '';
  String verificationId = '';

  bool isCodeSent = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  //region Methods
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: language.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        log(jsonEncode(selectedCountry.toJson()));
        setState(() {});
      },
    );
  }

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);

      toast(language.sendingOTP);

      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber:
              "+${selectedCountry.phoneCode}${numberController.text.trim()}",
          verificationCompleted: (PhoneAuthCredential credential) async {
            toast(language.verified);

            if (isAndroid) {
              await FirebaseAuth.instance.signInWithCredential(credential);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            appStore.setLoading(false);
            if (e.code == 'invalid-phone-number') {
              toast(language.theEnteredCodeIsInvalidPleaseTryAgain,
                  print: true);
            } else {
              toast(e.toString(), print: true);
            }
          },
          codeSent: (String _verificationId, int? resendToken) async {
            toast(language.otpCodeIsSentToYourMobileNumber);

            appStore.setLoading(false);

            verificationId = _verificationId;

            if (verificationId.isNotEmpty) {
              setState(() {
                isCodeSent = true;
              });
            } else {
              //Handle
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            FirebaseAuth.instance.signOut();
            setState(() {
              isCodeSent = false;
            });
          },
        );
      } on Exception catch (e) {
        log(e);
        appStore.setLoading(false);

        toast(e.toString(), print: true);
      }
    }
  }

  Future<void> submitOtp() async {
    log(otpCode);
    if (otpCode.validate().isNotEmpty) {
      if (otpCode.validate().length >= OTP_TEXT_FIELD_LENGTH) {
        hideKeyboard(context);
        appStore.setLoading(true);

        try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: otpCode);
          UserCredential credentials =
              await FirebaseAuth.instance.signInWithCredential(credential);

          Map<String, dynamic> request = {
            'username': numberController.text.trim(),
            'password': numberController.text.trim(),
            'login_type': LOGIN_TYPE_OTP,
            "uid": credentials.user!.uid.validate(),
          };

          try {
            await loginUser(request, isSocialLogin: true)
                .then((loginResponse) async {
              if (loginResponse.isUserExist.validate(value: true)) {
                await saveUserData(loginResponse.userData!);
                await appStore.setLoginType(LOGIN_TYPE_OTP);
                DashboardScreen().launch(context,
                    isNewTask: true,
                    pageRouteAnimation: PageRouteAnimation.Fade);
              } else {
                appStore.setLoading(false);
                finish(context);

                SignUpScreen(
                  isOTPLogin: true,
                  phoneNumber: numberController.text.trim(),
                  countryCode: selectedCountry.countryCode,
                  uid: credentials.user!.uid.validate(),
                  tokenForOTPCredentials: credential.token,
                ).launch(context);
              }
            }).catchError((e) {
              finish(context);
              toast(e.toString());
              appStore.setLoading(false);
            });
          } catch (e) {
            appStore.setLoading(false);
            toast(e.toString(), print: true);
          }
        } on FirebaseAuthException catch (e) {
          appStore.setLoading(false);
          if (e.code.toString() == 'invalid-verification-code') {
            toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
          } else {
            toast(e.message.toString(), print: true);
          }
        } on Exception catch (e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        }
      } else {
        toast(language.pleaseEnterValidOTP);
      }
    } else {
      toast(language.pleaseEnterValidOTP);
    }
  }

  // endregion

  Widget _buildMainWidget() {
    if (isCodeSent) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            32.height,
            OTPTextField(
              pinLength: OTP_TEXT_FIELD_LENGTH,
              textStyle: primaryTextStyle(),
              decoration: inputDecoration(context).copyWith(
                counter: Offstage(),
              ),
              onChanged: (s) {
                otpCode = s;
                log(otpCode);
              },
              onCompleted: (pin) {
                otpCode = pin;
                submitOtp();
              },
            ).fit(),
            30.height,
            AppButton(
              onTap: () {
                submitOtp();
              },
              text: language.confirm,
              color: primaryColor,
              textColor: Colors.white,
              width: context.width(),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: formKey,
            child: AppTextField(
              controller: numberController,
              textFieldType: TextFieldType.PHONE,
              decoration: inputDecoration(context).copyWith(
                prefixText: '+${selectedCountry.phoneCode} ',
                hintText: '${language.lblExample}: ${selectedCountry.example}',
                hintStyle: secondaryTextStyle(),
              ),
              autoFocus: true,
              onFieldSubmitted: (s) {
                sendOTP();
              },
            ),
          ),
          30.height,
          AppButton(
            onTap: () {
              sendOTP();
            },
            text: language.btnSendOtp,
            color: primaryColor,
            textColor: Colors.white,
            width: context.width(),
          ),
          16.height,
          AppButton(
            onTap: () {
              changeCountry();
            },
            text: language.lblChangeCountry,
            textStyle: boldTextStyle(),
            width: context.width(),
          ),
        ],
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: Text(isCodeSent ? language.confirmOTP : language.lblEnterPhnNumber, style: boldTextStyle(size: APP_BAR_TEXT_SIZE)),
      //   elevation: 0,
      //   backgroundColor: context.scaffoldBackgroundColor,
      //   leading: Navigator.of(context).canPop() ? BackWidget(iconColor: context.iconColor) : null,
      //   scrolledUnderElevation: 0,
      //   systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark, statusBarColor: context.scaffoldBackgroundColor),
      // ),
      // body: Body(
      //   child: Container(
      //     padding: EdgeInsets.all(16),
      //     child: _buildMainWidget(),
      //     decoration: BoxDecoration(
      //       image: DecorationImage(
      //           image: AssetImage(
      //               'assets/otp_background.png'
      //           )
      //       )
      //     ),
      //   ),
      // ),
      body: Stack(fit: StackFit.expand, children: [
        Image.asset(
          'assets/otp_background.png',
          height: context.height(),
          width: context.width(),
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              160.height,
              // Form(
              //   key: formKey,
              //  )
              //   AppTextField(
              //     controller: numberController,
              //     textFieldType: TextFieldType.PHONE,
              //     decoration: inputDecoration(context).copyWith(
              //       prefixText: '+${selectedCountry.phoneCode} ',
              //       hintText: '${language.lblExample}: ${selectedCountry.example}',
              //       hintStyle: secondaryTextStyle(),
              //     ),
              //     autoFocus: true,
              //     onFieldSubmitted: (s) {
              //       sendOTP();
              //     },
              //   ),
              // ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Text(
                      '+20 ',
                      style: GoogleFonts.raleway().copyWith(fontSize: 22),
                    ),
                    8.width,
                    Container(
                      width: 2,
                      height: 30,
                      decoration: BoxDecoration(color: Colors.black38),
                    ),
                    12.width,
                    Expanded(
                      child: TextField(
                        controller: numberController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 24, color: Colors.black45),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                            hintText: "MOBILE NUMBER",
                            hintStyle: TextStyle(fontSize: 24, color: Colors.grey),
                            border: InputBorder.none),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Image.asset(
                        'assets/phone_call.png',
                        width: 20,
                        height: 20,
                        color: Colors.black87,
                      ),
                    )
                  ],
                ),
              ),
              30.height,
              AppButton(
                onTap: () {
                  sendOTP();
                },
                text: "LOGIN",
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
                color: primaryColor,
                width: context.width(),
              ),
              60.height,
              TextButton(onPressed: () {}, child: Text('Register as pro')),
              60.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Skip',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.grey,
                        width: 2.0
                      )
                    )
                  ),
                ],
              ),
              50.height
            ],
          ),
        ),
      ]),
    );
  }
}
