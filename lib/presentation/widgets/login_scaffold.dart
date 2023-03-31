import 'package:flutter/material.dart';

class LoginScaffold extends StatelessWidget {
  final String title;
  final Widget? description;
  final Widget? body;
  final String? hint;
  final Widget? footer;
  final Widget? bottom;

  const LoginScaffold({
    super.key,
    required this.title,
    this.description,
    this.body,
    this.hint,
    this.footer,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisSize:  MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    title
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: description
                ),

                if(body != null) Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: body!,
                ),
                
                if(hint != null) Text(hint!, style: Theme.of(context).textTheme.bodySmall,),

                if(footer != null) Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: footer,
                )
              ]
            ),

            if(bottom != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: bottom,
                )
              )
          ],
        ),
      );
  }
}