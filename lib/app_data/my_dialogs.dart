import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'constants.dart';

class MyDialog {
  static infoDialog(BuildContext context, {
    required String title,
    required String body,
    String? confirmText,
    String? cancelText,
    Function? onConfirm,
    Function? onCancel,
    bool showOnCancel = false,
  }) {
    Color dialogColor = CupertinoColors.systemYellow;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
  static warningDialog (BuildContext context, {
    required String title,
    required String body,
    String? confirmText,
    String? cancelText,
    Function? onConfirm,
    Function? onCancel,
    bool showOnCancel = false,
  }) {
    Color dialogColor = CupertinoColors.systemYellow;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }


  static errorDialog(BuildContext context, {
    required String title,
    required String body,
    String? confirmText,
    String? cancelText,
    Function? onConfirm,
    Function? onCancel,
    bool showOnCancel = false,
  }) {
    Color dialogColor = CupertinoColors.systemRed;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  static successDialog(BuildContext context, {
    required String title,
    required String body,
    String? confirmText,
    String? cancelText,
    Function? onConfirm,
    Function? onCancel,
    bool showOnCancel = false,
  }) {
    Color dialogColor = CupertinoColors.systemGreen;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }


  static confirmDialog(BuildContext context, {
    required String title,
    required String body,
    String? confirmText,
    String? cancelText,
    Function? onConfirm,
    Function? onCancel,
    bool showOnCancel = false,
  }) {
    Color dialogColor = mainColor;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }


  static loadingDialog(BuildContext context, {
    required String title,
    String? body,
    String? confirmText,
    String? cancelText,
    Function? onConfirm,
    Function? onCancel,
    bool showOnCancel = false,
  }) {
    Color dialogColor = mainColor;
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  static customDialog(BuildContext context,

      {
        required String title,
        String? body,
        String? confirmText,
        String? cancelText,
        Function? onConfirm,
        Function? onCancel,
        bool showOnCancel = false,
        bool showOnConfirm = true,
        QuickAlertType? quickAlertType,
        Color? thisDialogColor,
        required Widget widget,
      }) {
    Color dialogColor = thisDialogColor ?? mainColor;
    return QuickAlert.show(
      context: context,
      type: quickAlertType ?? QuickAlertType.confirm,
      widget: widget,
      text: body,
      title: title,
      titleColor: dialogColor,
      confirmBtnText: confirmText ?? 'ok'.tr,
      cancelBtnText: cancelText ?? 'cancel'.tr,
      onConfirmBtnTap: () {
        if (onConfirm != null) {
          Get.back();
          onConfirm();
        } else {
          Get.back();
        }
      },
      onCancelBtnTap: onCancel != null ? onCancel() : null,
      showCancelBtn: showOnCancel,
      showConfirmBtn: showOnConfirm,
      confirmBtnColor: dialogColor,
      barrierColor: mainColor.withOpacity(.3),
      headerBackgroundColor: dialogColor,
      confirmBtnTextStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }


}
