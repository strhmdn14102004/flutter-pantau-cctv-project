// ignore_for_file: deprecated_member_use

import "dart:ui";

import "package:base/base.dart";
import "package:flutter/material.dart";

Future<void> showGlassDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String positiveText,
  required String negativeText,
  required VoidCallback positiveCallback,
}) async {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Dimensions.size10,
          sigmaY: Dimensions.size10,
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(Dimensions.size20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.size20),
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: Dimensions.size1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimensions.size20),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.text18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: Dimensions.size1,
                  color: Colors.white.withOpacity(0.1),
                ),
                Padding(
                  padding: EdgeInsets.all(Dimensions.size20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: Dimensions.text16,
                    ),
                  ),
                ),
                Container(
                  height: Dimensions.size1,
                  color: Colors.white.withOpacity(0.1),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(Dimensions.size20),
                            ),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(Dimensions.size15),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  negativeText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Dimensions.text16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: Dimensions.size1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(Dimensions.size20),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              positiveCallback();
                            },
                            child: Container(
                              padding: EdgeInsets.all(Dimensions.size15),
                              child: Center(
                                child: Text(
                                  positiveText,
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: Dimensions.text16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
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
      );
    },
  );
}
