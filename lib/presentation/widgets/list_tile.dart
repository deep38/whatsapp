import 'package:flutter/material.dart';

class WhatsAppListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailingText;
  final List<Widget>? trailingIcons;
  final bool selected;

  final Function()? onTap;
  final Function()? onLongPress;

  const WhatsAppListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailingIcons,
    this.trailingText,
    this.selected = false,

    this.onTap,
    this.onLongPress,
  });

  final double _kPadding = 16;

  final double _kLeadingSize = 50;

  @override
  Widget build(BuildContext context) {
    
    return Container(
      
      height: 82,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      color: selected ? Theme.of(context).listTileTheme.selectedColor : Theme.of(context).listTileTheme.tileColor,
      
      child: Material(

        color: Colors.transparent,

        child: InkWell(

          onTap: onTap,
          onLongPress: onLongPress,

          child: Row(
      
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
      
            children: [

              Container(
                padding: EdgeInsets.all(_kPadding),
                width: 82,
                height: 82,

                child: Stack(

                  alignment: Alignment.center,
                  fit: StackFit.expand,

                  children: [

                    leading,

                    Positioned(

                      right: 0,
                      bottom: 0,

                      child: AnimatedScale(
                        scale: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                      
                          // duration: Duration(milliseconds: 200),  
                          width: 22,
                          height: 22,
                          
                          alignment: Alignment.center,
                          
                        
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).canvasColor,
                              width: 1.5,
                            ),
                          ),
                        
                          child: const Icon(
                            Icons.check, 
                            color: Colors.white, 
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                )
              ),

              Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                      
                children: [
                      
                  SizedBox(
                    width: MediaQuery.of(context).size.width - (3 * _kPadding) - _kLeadingSize,
                    child: Row(
                  
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                        
                      children: [
                        DefaultTextStyle(
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
                          child: title,
                        ),

                        if(trailingText != null) DefaultTextStyle(
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.labelMedium ?? const TextStyle(),
                          child: trailingText!
                        )
                      ],
                    ),
                  ),

                  SizedBox.fromSize(size: const Size(0, 2),),

                  SizedBox(
                    width: MediaQuery.of(context).size.width - (3 * _kPadding) - _kLeadingSize,
                    
                    child: Row(
    
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
      
                      children: [
                        if(subtitle != null)
                          SizedBox(
                            width: MediaQuery.of(context).size.width - (3 * _kPadding) - _kLeadingSize - 8 - (18 * (trailingIcons?.length ?? 0)),
                            child: DefaultTextStyle(
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
                              maxLines: 1,
                              child: subtitle!
                            ),
                          ),

                        if(trailingIcons != null) 
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: trailingIcons!,
                          )
                      ],
                    ),
                  )
                      
                ],
              ),

              SizedBox(
                width: _kPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}