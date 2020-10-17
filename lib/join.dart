import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:poptrivia/create.dart';
import 'package:poptrivia/dbHandler.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'game/game.dart';


class Join extends StatefulWidget {
  final String userName;
  Join(this.userName);

  _JoinState createState() => _JoinState();
}

class _JoinState extends State<Join> {
  String name = '';
  String roomNumber = '';
  TextEditingController tcon = new TextEditingController();
  TextEditingController rcon = new TextEditingController();

  @override
  void initState() {
    name = widget.userName;
    tcon.text = name;
    super.initState();
  }


  Future<void> errorDialog(String error) async {



showDialog(context: context,
builder: (BuildContext context){
  return AlertDialog(
    content: Container(
      height: 160,
      width: 400,
      child: 

    Center(child: 
    Text('$error',
    style: GoogleFonts.anton(
    color: MyTheme().titleTextColor(),
    fontSize: 38,
    
    ),
    textAlign: TextAlign.center,
    ),
    ),
    ),
    backgroundColor: MyTheme().backgroundColor(),



  );



}

);
Future.delayed(Duration(seconds: 1)).then((value){
if(error == 'Success'){
print('go to next page');
Navigator.pop(context);
DBHandler().addPlayer(int.parse(roomNumber), name);
 Navigator.push(context, PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Waiting(roomNumber, name)
              ));
}else{
  Navigator.pop(context);
}

});

}










  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme().backgroundColor(),
      appBar: AppBar(
        backgroundColor: MyTheme().backgroundColor(),
        centerTitle: true,
        title: MyTheme().title('Join a Game!',22, false, false),
      ),
      body: Center(
        child: Column(
          children: [

                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width - 50,
                  decoration: new BoxDecoration(
                  color: MyTheme().backgroundColor(),

                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Padding(
                      padding: EdgeInsets.only(bottom:45),
                      child: MyTheme().title('#', 58, true, false)),

                    Container(
                      height: 60,
                      width: 180,
                      child: TextField(
                      controller: rcon,
                      onChanged: (text){
                        setState(() {
                         roomNumber = text; 
                        });
                      },
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                       
                      ),
                      style: GoogleFonts.anton(
                        color: MyTheme().titleTextColor(),
                        fontSize: 58,
                         shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(4,3)
                          )
                        ]
                      ),
                  ),
                    ),
                
               
                  ],)
                  
                    ),


              MyTheme().textField('Name', name, tcon, 
              (text){
                setState(() {
                 name = text; 
                });
              }),

              Padding(
                padding: const EdgeInsets.only(top:45),
                child: MyTheme().button('Join Game!', 
                (){
                  //GAME JOIN LOGIC
                  DBHandler().joinRoom(name, roomNumber).then((value){
                    errorDialog(value);
                  });
                }),
              )
          ],
        ),
      ),

    );
  }
}



class Waiting extends StatefulWidget {
  final String roomNum;
  final String name;
  Waiting(this.roomNum, this.name);

  _WaitingState createState() => _WaitingState();
}

class _WaitingState extends State<Waiting> {
  DatabaseReference _ref = new FirebaseDatabase().reference();
  Key _scafKey;

  @override
  void initState() {
    getData();
        _ref.child('Rooms').child(widget.roomNum.toString()).onChildChanged.listen((event) {
          print(event.snapshot.key);
            getData();
            if(event.snapshot.key == ('Questions')){
               Navigator.push(context, PageTransition(
                type: PageTransitionType.rightToLeft,
                child: Game(int.parse(widget.roomNum), false, widget.name, int.parse(amount))
              ));
            }
        });
        //    _ref.child('Rooms').child(widget.roomNum.toString()).onChildChanged.listen((event) {
        //   print('child was changed...');
        //     getData();
        // });
    super.initState();
  }

  String category = 'Category...';
  String difficulty = '';
  String amount = ''; 
  Future<bool> getData() async{
    int r = int.parse(widget.roomNum);
    String temp = '';
    try {
    await DBHandler().getCategory(r).then((value){setState((){ category = value;});});
    await DBHandler().getDifficulty(r).then((value){setState((){ temp = value;});});
    await DBHandler().getAmount(r).then((value){setState((){ amount = value;});});
    } catch (e) {
      category = '';
    }

    switch (temp) {
      case '0':
        difficulty = 'Easy' ;
        
        break;
      case '1':
      difficulty = 'Medium' ;
      break;
      case '2':
      difficulty = 'Hard' ;
      break;
      default:
    }
       
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyTheme().backgroundColor(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
          child: Column(
            children: [
              
                    MyTheme().title('Category: ${category.substring(0, category.indexOf(':'))}', 36, false, false),
                    MyTheme().title('Questions: $amount', 30, false, false),
                    MyTheme().title('Difficulty: $difficulty', 24, false, false),
                  
                
                  SizedBox(
                  width: 250.0,
                  child: TypewriterAnimatedTextKit(
                    repeatForever: true,
                    isRepeatingAnimation: true,
                    speed: Duration(milliseconds: 300),
                    text: [
                      "Waiting for Host...",
                    ],
                    textStyle: GoogleFonts.anton(
                      color: Colors.black,
                      fontSize: 32
                    ),
                    textAlign: TextAlign.start,
                    alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                  ),
                ),



              PlayersWaiting(int.parse(widget.roomNum)),
            ],
          ),
        ),
    );
  }
}