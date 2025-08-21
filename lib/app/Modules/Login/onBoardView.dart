import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentem/app/Utils/font_styles.dart';

class OnBoardView extends ConsumerWidget {
  const OnBoardView({super.key});
  static const Color pastelYellow = Color(0xFFFFF089);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: pastelYellow,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text("Rentem",
                  //     style: FontStyles.heading.copyWith(
                  //       color: Colors.black,
                  //       fontSize: 32,
                  //     )),
                  Image.asset(
                    'assets/images/onBoardHouse.png', // Ensure this path matches your assets
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height:
                        MediaQuery.of(context).size.height *
                        0.4, // Adjust height as needed
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  spacing: 35,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Handle your Tenant with Ease",
                      style: FontStyles.heading.copyWith(
                        color: Colors.black,
                        fontSize: 44,
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black54,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                        onPressed: () {
                          context.push('/login');
                        },
                        child: Text("Continue ->", style: FontStyles.body,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
