import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:poptrivia/dbHandler.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:page_transition/page_transition.dart';

import 'dbHandler.dart';
import 'my_theme.dart';
import 'trivaHandler.dart';
import 'package:html_unescape/html_unescape.dart';

class Game extends StatefulWidget{
  final int roomNum;
  final bool host;
  final String name;
  final List<String> players;
  Game(this.roomNum, this.host, this.name, this.players);
  @override
  State<StatefulWidget> createState() => _Game();

}

class _Game extends State<Game>{
  DatabaseReference _ref = new FirebaseDatabase().reference();
List<bool> lockList = [false];
  var unescape = new HtmlUnescape();
  Timer _timer;
  int _start = 30;
  Offset timerOffset = Offset(0,200);
  double timerHeight = 200;
  double timerWidth = 300;
  double timerRadius = 28;
  double timerBorderWidth = 12;
  double timerFontSize = 82;
  AnimationController controller;
  Animation<double> animation;
  Map<dynamic,dynamic> questions = new Map();
  bool roundOver = false;
  int questionNum = 0;
  bool lockedIn = false;
  String title = '';
  String answer = '';
  List<dynamic> questionList = new List();
  bool allPlayersLocked = false;
  @override
  void initState() {

    if(widget.host){

      getTrivia();
      introAnim();


    }else{

      introAnim();

    }
    
    _ref.child('Rooms').child(widget.roomNum.toString()).child('Players').onChildAdded.listen((event){

    });
    _ref.child('Rooms').child(widget.roomNum.toString()).child('Questions').onChildAdded.listen((event) {
    
 
      _ref.child('Rooms').child(widget.roomNum.toString()).child('Questions').once().then((value) {
          // setState(() {
            questionList = value.value;
          // });

          questionList.forEach((element) { 
            if(element.contains('Answer:')){
              // setState(() {
                answer = element.substring(7);
              // });

            }
          });

      });

    });
    super.initState();
  }


Future<void> stupid() async {
_ref.child('Rooms').child(widget.roomNum.toString()).child('Players').child(widget.name).once().then((DataSnapshot data){
if(data.value.toString().length > 1){
  setState(() {
   lockedIn = true; 
  });
}
});
}



Future<void> getTrivia() async{
  
String category = await DBHandler().getCategory(widget.roomNum);
String amount = await DBHandler().getAmount(widget.roomNum);
String difficulty = await DBHandler().getDifficulty(widget.roomNum);
questions = await TriviaHandler().createTrivia(int.parse(amount), int.parse(category.substring(category.indexOf(':') + 1)), int.parse(difficulty));
splitData(questions[questionNum]);

}

void splitData(dynamic qPack){
String q = qPack.toString();
title = unescape.convert(q.substring(q.indexOf('question: ') + 9, q.indexOf(', correct_answer')));

setState(() {

answer = q.substring(q.indexOf('correct_answer: ') + 16, q.indexOf(', incorrect'));
questionList = unescape.convert(q.substring(q.indexOf('[') + 1, q.indexOf(']'))).split(',');
questionList.add('Answer:'+answer);
questionList.shuffle();

});


DBHandler().pushTriva(questionList, widget.roomNum);

}




Future<void> answerDialog(bool correct) async {



showDialog(context: context,
builder: (BuildContext context){
  return AlertDialog(
    content: Container(
      height: 200,
      width: 400,
      child: correct? 
    Center(child: 
    Text('Correct!\n+100',
    style: GoogleFonts.anton(
      color: Colors.green,
      fontSize: 48
    ),
        textAlign: TextAlign.center,

    ))
    : 

    Center(child: 
    Text('Incorrect\n$answer',
    style: GoogleFonts.anton(
    color: MyTheme().titleTextColor(),
    fontSize: 48,
    
    ),
    textAlign: TextAlign.center,
    ),
    ),
    ),
    backgroundColor: MyTheme().backgroundColor(),



  );



}

);

Future.delayed(Duration(seconds: 3)).then((value){
Navigator.pop(context);
});

}



Future<void> introAnim() async{
  Future.delayed(Duration(milliseconds: 800)).then((value) {
      setState(() {
      timerHeight = 50;
      timerWidth = 75;
      timerRadius = 8;
      timerBorderWidth = 2;
      timerFontSize = 32;

      });
      if(widget.host){
      splitData(questions[questionNum]);
      }
      startTimer();
  });
}

Future<void> addPoints() async{
   await DBHandler().isCorrect(widget.roomNum, widget.name).then((correct){
    if(correct){
    
      DBHandler().addPoints(widget.roomNum, widget.name, 100);
      //CORRECT!!
      answerDialog(correct);
    }else{
      //WRONG!!
     answerDialog(correct);
    }

  });
}


Future<void> resetAnim() async{

    addPoints();
    _LockedInState().clearLockList();
  Future.delayed(Duration(seconds: 4)).then((value) {
    setState(() {
      DBHandler().lockOut(widget.roomNum, widget.name);
      lockedIn = false;
      timerHeight = 200;
      timerWidth = 300;
      timerRadius = 28;
      timerBorderWidth = 12;
      timerFontSize = 82;
      _start = 30;
      });
      introAnim();
  });
}

void startTimer() {
  const oneSec = const Duration(seconds: 1);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) => setState(
      () {

        checkLocked();
        if(!lockList.contains(false)){
          timer.cancel();
            setState(() {
            lockList = [false];
            roundOver = true;
            questionNum = questionNum +1;     
            resetAnim();
          });
        }
       print('$questionNum / ${questions.length}');
      if(questionNum >= questions.length){
        addPoints();
          print('GAME OVER');
             Navigator.push(context, PageTransition(
        type: PageTransitionType.rightToLeft,
        child: GameOver(widget.roomNum,widget.players)
      ));

      } 

        if (_start < 1) {
          timer.cancel();
          if(questionNum <= questions.length){
            print('ROUND OVER ->');
            setState(() {
            roundOver = true;
            questionNum = questionNum +1;     
            resetAnim();
          });
   
      
          }
          
        } else {
          setState(() {
          _start = _start - 1;
          });
        }
      },
    ),
  );
}


  Future<void> checkLocked() async {
    for(int i = 0; i < widget.players.length; i++){
        var temp = await DBHandler().isLocked(widget.roomNum, widget.players[i]);
          lockList.add(temp);    
      
      }
      
  }




@override
void dispose() {
  _timer.cancel();
  DBHandler().deleteRoom(widget.roomNum);
  super.dispose();
}







  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
          child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyTheme().backgroundColor(),
        body: Center(
          child: Column(
            children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: AnimatedContainer(
                          duration: Duration(milliseconds:800),
                          height: timerHeight,
                          width: timerWidth,
                          decoration: new BoxDecoration(
                       border: Border.all(
                         color: MyTheme().titleTextColor(),
                         width: timerBorderWidth,
                       ),
                       borderRadius: BorderRadius.circular(timerRadius)
                          ),
                          child: Center(child: AnimatedDefaultTextStyle(child: Text(_start.toString().length>1?'0:$_start':'0:0$_start',),
                           style: GoogleFonts.anton(
                            fontSize: timerFontSize,
                            color: Colors.grey[800]
                          ), 
                          
                          duration: Duration(milliseconds: 800))
                          
                          ),
                        ),
                    ),

                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title,
                    textAlign: TextAlign.center,
                    ),
                  ),
                ),
                !lockedIn? Container(
                  height: 340,
                  width: MediaQuery.of(context).size.width - 50,
                  child: GridView.builder(
                    gridDelegate:new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: questionList.length,
                    itemBuilder: (BuildContext context, int index){
                      return questionList[index] != '-X-'? Padding(
                        padding: const EdgeInsets.fromLTRB(18.0, 50,18,50),
                        child: InkWell(
                          onTap: (){
                            if(questionList[index].contains('Answer:')){
                              print('Correct!');
                              DBHandler().lockIn(widget.roomNum, widget.name, questionList[index]);
                              stupid();  
                            }else{
                              print('Incorrect!');
                              DBHandler().lockIn(widget.roomNum, widget.name, questionList[index]);
                              stupid();
                            }
                          },
                            child:  AnimatedContainer(
                            duration: Duration(milliseconds:200),
                            height:  20,
                            width: 180,
                            decoration: new BoxDecoration(
                              color:  !(questionList[index] == 'Correct!')? MyTheme().titleTextColor(): Colors.green,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Center(child: Text(
                              questionList[index].contains('Answer:')?
                              questionList[index].substring(7):(questionList[index]),
                            style: GoogleFonts.anton(
                              color: Colors.grey[800]
                            ),
                            textAlign: TextAlign.center,
                            )),
                          )
                        ),
                      ):Container();
                    },


                  ),
                      ): Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: 200,
                            decoration: new BoxDecoration(
                              color: MyTheme().titleTextColor(),
                              borderRadius: BorderRadius.circular(18),
                          
                            ),
                            child: Center(
                              child: Text('LOCKED IN',
                              style: GoogleFonts.anton(
                                color: MyTheme().backgroundColor(),
                                fontSize: 28
                              ),
                              ),
                            ),


                          ),
                        ),
                      ),
                LockedIn(widget.roomNum,widget.name)
            ],
          )
        ),
      ),
    );
  }

}



class LockedIn extends StatefulWidget {
  final int roomNum;
  final String name;
  LockedIn(this.roomNum, this.name);

  _LockedInState createState() => _LockedInState();
}

class _LockedInState extends State<LockedIn> {
DatabaseReference _ref = new FirebaseDatabase().reference();

List<String> players = new List();
bool locked = false;
List<bool> lockList = [false];

  @override
  void initState() { 
     _ref.child('Rooms').child(widget.roomNum.toString()).child('Players').onChildChanged.listen((event){
       fillLocked();
     });
    super.initState();
    
  }

  void clearLockList(){

    setState(() {
     lockList = [false]; 
    });
  }

 

  Future<void> fillLocked() async {
    for(int i = 0; i < players.length; i++){
        var temp = await DBHandler().isLocked(widget.roomNum, players[i]);
                lockList.add(temp);   

      
      }
  print(lockList);
  }





  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width-20,
      height: 150,
       child: 
       GridView.builder(
         gridDelegate:new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
         itemCount: players.length,
         itemBuilder: (BuildContext context, int index) {
         return Padding(
           padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
           child: 
           Center(child: 
           Column(
             children: [
           Icon(          
           !lockList[index]? Icons.lock_open_outlined: Icons.lock,
           color: !lockList[index]? Colors.black: Colors.green,
           ),

           Text(players[index]),
             FutureBuilder(
               future: DBHandler().getPoints(widget.roomNum, players[index]),
               builder: (BuildContext context, AsyncSnapshot snapshot) {
                 return Text(snapshot.data.toString(),
                 style: GoogleFonts.dmSans(
                   fontWeight: FontWeight.bold

                 ),
                 
                 );
               },
             ),
             ],
           )
           
           
           
           ),
         );
       
       
         },
       ),
       
       
    );
  }
}


class GameOver extends StatefulWidget {
  final int roomNum;
  final List<String> players;

  GameOver(this.roomNum, this.players);

  _GameOverState createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {


    @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
String winner = '';

  Future<void> getWinners() async {
    var temp = 0;
    widget.players.forEach((player) async {
      var score = await DBHandler().getPoints(widget.roomNum, player);
      if(temp == 0){
        temp = score;
        winner = player;
      }else{
        if(score > temp){
          temp = score;
          winner = player;
        }
      }





    });


  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme().backgroundColor(),
       body: 
       Center(
         child: Column(
           children: [
             MyTheme().title('Game Over', 48, true, true),
             
              Container(
                    height: 400,
                    width: MediaQuery.of(context).size.width - 50,

                    child: GridView.builder(
                      itemCount: widget.players.length,
                    gridDelegate:new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemBuilder: (BuildContext context, int index) { 

                          return Container(child: 
                          Column(children: [
                          Text(widget.players[index]),
                          FutureBuilder(
                            future: DBHandler().getPoints(widget.roomNum, widget.players[index]),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              return Text(snapshot.data.toString());
                            },
                          ),

                          ],)
                          
                          ,);

                      },

                    ),


                  ),
           ],
         ),
       ),
       
     
    );
  }
}