import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/presentation/pages/login/enter_phone_number_page.dart';
import 'package:whatsapp/presentation/widgets/whatsapp_elevated_button.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 56,),
              Padding(
                padding: const EdgeInsets.all(44),
                child: Image.asset(
                  AssetImages.intro,
                  scale: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text("Welcome to WhatsApp", style: Theme.of(context).textTheme.bodyLarge,),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    text: "Read our ",
                    children: [
                      TextSpan(
                        text: "Privacy Policy",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue
                        ),
                        recognizer: TapGestureRecognizer()..onTap =() {
                          showSnackBar(context, "Privacy Policy");
                        }
                      ),
                      const TextSpan(
                        text: ". Tap \"Agree and continue\" to accept the "
                      ),
                      TextSpan(
                        text: "Terms of Service",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue
                        ),
                        recognizer: TapGestureRecognizer()..onTap =() {
                          showSnackBar(context, "Terms of Service");
                        }
                      ),
                      const TextSpan(
                        text: "."
                      )
                    ]
                  ),
                  textAlign: TextAlign.center,
                  
                ),
              ),
              const SizedBox(height: 20,),
              WhatsAppElevatedButton(
                onPressed: () => navigateTo(context, const EnterPhoneNumberPage()),
                child: const Text(
                  "AGREE AND CONTINUE",
                )
              )
            ],
          ),
        ),
      )
    );
  }
}