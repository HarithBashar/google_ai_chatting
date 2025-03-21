import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/app_data/constants.dart';
import 'package:google_ai_chat/app_data/my_dialogs.dart';
import 'package:google_ai_chat/ui/settings/settings_class.dart';

int animationTime = 0;

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Settings"),
      ),
      body: Stack(
        children: [
          backgroundImage,
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GetBuilder(
                      init: SettingsClass(),
                      builder: (controller) {
                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white10,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(top: 10),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Background Image Opacity',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                      Switch(
                                        value: controller.backgroundImageOpacity != 0,
                                        activeColor: mainColor,
                                        onChanged: (x) async {
                                          animationTime = 300;
                                          if (x) {
                                            // Set a specific opacity when enabled
                                            controller.changeBackgroundImageOpacity(controller.box.read('backgroundImageOpacity') ?? .1);
                                          } else {

                                            // Disable background and set opacity to 0
                                            controller.changeBackgroundImageOpacity(0, isBackgroundDisabled: true);
                                          }
                                          await Future.delayed(const Duration(milliseconds: 250));
                                          animationTime = 0;

                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GetBuilder<SettingsClass>(
                                          builder: (controller) {
                                            return TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: controller.backgroundImageOpacity, end: controller.backgroundImageOpacity),
                                              duration: Duration(milliseconds: animationTime),
                                              builder: (context, value, child) {
                                                return Slider(
                                                  value: value,
                                                  onChanged: (x) {
                                                    controller.changeBackgroundImageOpacity(x);
                                                  },
                                                  min: 0,
                                                  max: .2,
                                                  thumbColor: mainColor,
                                                  activeColor: mainColor.withOpacity(.3),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      GetBuilder<SettingsClass>(
                                        builder: (controller) {
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                              begin: controller.backgroundImageOpacity,
                                              end: controller.backgroundImageOpacity,
                                            ),
                                            duration: Duration(milliseconds: animationTime),
                                            builder: (context, value, child) {
                                              return Text(
                                                (value / 0.2 * 100).toStringAsFixed(0), // Convert value to percentage
                                                style: const TextStyle(fontSize: 16),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),


                                ],
                              ),
                            ),
                          ],
                        );
                      },),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    MyDialog.confirmDialog(context, title: "Logout", body: "Are you sure to logout?", showOnCancel: true, onConfirm: () async {
                      await FirebaseAuth.instance.signOut();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor.withOpacity(.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                    alignment: Alignment.center,
                    child: const Text('Logout', style: TextStyle(fontSize: 20, color: Colors.white70)),
                  ),
                ),
                Text(
                  "version $version",
                  style: const TextStyle(color: Colors.white60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
