import 'package:flutter/material.dart';
import 'package:poptrivia/create.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:page_transition/page_transition.dart';

import 'join.dart';


class LobbyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LobbyPage();

}

class _LobbyPage extends State<LobbyPage>{

  AnimationController titleCon;
  TextEditingController nCon;
  String name = '';

  @override
  void initState() {     
    super.initState();
  }

 







Widget buttonGroup(){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

     MyTheme().button('Join', (){
       if(name.length>=1){
        print('Going to Join Page...');
        Navigator.push(context, PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Join(name)
              ));
       }
        
     } ),
    MyTheme().button('Create', (){
      if(name.length >= 1){
     print('Goin to Create Page...');
      Navigator.push(context, PageTransition(
        type: PageTransitionType.rightToLeft,
        child: CreatePage(name)
      ));
      }
 
    } )

    ],),
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyTheme().backgroundColor(),
        body: Center(
          child: Column(
            children: [
              MyTheme().title('POP\nTRIVIA', 82, true, true),
              MyTheme().textField('Name', name, nCon, (text){
                setState(() {
                 name = text; 
                });
              }),
              buttonGroup()
            ],
          ),
        ),
    );
  }

}