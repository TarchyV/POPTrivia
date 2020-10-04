

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {


Color backgroundColor() {
  return Colors.amber[300];
}

Color titleTextColor() {
  return Colors.red[400];
}

Color inputColor() {
  return Colors.grey[800];
}

Widget button(String text, Function fun,){

return Padding(
  padding: const EdgeInsets.all(8.0),
  child:   InkWell(
    onTap: fun,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 150,
      height: 50,
      decoration: new BoxDecoration(
          color: MyTheme().titleTextColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
            color: Colors.black,
            offset: Offset(4,3)
            )
          ]
      ), 
      child:Center(
        child: Text(text,
        textAlign: TextAlign.center,
        style: GoogleFonts.anton(
          fontSize: 16,
        ),
        ),
      ),
    ),
  ),
);

}



Widget textField(String title, String t, TextEditingController nCon, Function(String) onchanged, ){
  return Column(
    children: [
      Text(
        title,
        style: GoogleFonts.anton(
          color: MyTheme().inputColor(),
          fontSize: 18
        ),
      ),
      Container(
          width: 250,
          height: 50,
          decoration: new BoxDecoration(
            color: MyTheme().inputColor(),
            borderRadius: BorderRadius.circular(12)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: nCon,
              onChanged: onchanged,
              textAlign: TextAlign.center,
              maxLength: 20,
              style: GoogleFonts.dosis(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterStyle: TextStyle(fontSize: 0),
                              
              ),
            ),
          ),
      ),
    ],
  );
  
  
  

}
  AnimationController titleCon;

Widget title(String text, double fontSize,bool shadow, bool animate){
  return Padding(
    padding: const EdgeInsets.all(18.0),
    child: Dance(
          animate: animate,
          controller: ( controller ) => titleCon = controller,
          child: InkWell(
            onTap: (){
              titleCon.reset();
              titleCon.forward(); 
            },
        child: Text(text,
        style: GoogleFonts.anton(
            color: MyTheme().titleTextColor(),
            fontSize: fontSize,
            shadows: [
             shadow? Shadow(
                color: Colors.black,
                offset: Offset(4,3)
              ): Shadow()
            ]
        ),
        textAlign: TextAlign.center, 
        ),
          ),
    ),
  );
}
}