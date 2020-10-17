import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:poptrivia/dbHandler.dart';

import 'package:page_transition/page_transition.dart';

import 'package:html_unescape/html_unescape.dart';

import '../trivaHandler.dart';
import 'game_over.dart';

class Game extends StatefulWidget{
  final int roomNum;
  final bool host;
  final String name;
  final int amount;
  Game(this.roomNum, this.host, this.name, this.amount);
  @override
  State<StatefulWidget> createState() => _Game();

}

class _Game extends State<Game>{
  DatabaseReference _ref = new FirebaseDatabase().reference();
List<bool> lockList = [false];
  var unescape = new HtmlUnescape();
  Timer _timer;
  int _start = 30;
  List<String> players = new List();
  Offset timerOffset = Offset(0,200);
  double timerHeight = 200;
  bool gameOver = false;
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
    getPlayers();
    if(widget.host){

      getTrivia();
      introAnim();


    }else{

      introAnim();

    }
    
    _ref.child('Rooms').child(widget.roomNum.toString()).child('Players').onChildChanged.listen((event){
        checkLocked();

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


  Future<List<String>> getPlayers() async{
         await DBHandler().getPlayers(widget.roomNum).then((value){

          setState(() {
           players = value; 
          });

         });
        //  print(players);
    return players;
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
title = await DBHandler().getTitle(widget.roomNum);
String category = await DBHandler().getCategory(widget.roomNum);
String amount = await DBHandler().getAmount(widget.roomNum);
String difficulty = await DBHandler().getDifficulty(widget.roomNum);
questions = await TriviaHandler().createTrivia(int.parse(amount), int.parse(category.substring(category.indexOf(':') + 1)), int.parse(difficulty));
splitData(questions[questionNum]);

}


Future<void> nextQuestion() async{

questionNum = await DBHandler().getQuestionNum(widget.roomNum);

setState(() {
 questionNum = questionNum + 1; 
});

await DBHandler().questionNum(questionNum, widget.amount, widget.roomNum);



}



void splitData(dynamic qPack){
String q = qPack.toString();
try {
  DBHandler().pushTitle(widget.roomNum, unescape.convert(q.substring(q.indexOf('question: ') + 9, q.indexOf(', correct_answer')))); 

  setState(() {

answer = q.substring(q.indexOf('correct_answer: ') + 16, q.indexOf(', incorrect'));
questionList = unescape.convert(q.substring(q.indexOf('[') + 1, q.indexOf(']'))).split(',');
questionList.add('Answer:'+answer);
questionList.shuffle();

});
DBHandler().pushTriva(questionList, widget.roomNum);

} catch (e) {
  questions.clear();
  getTrivia();
}





}

Future<void> answerDialog(bool correct) async {



!gameOver? showDialog(context: context,
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

): print('gameisover');

!gameOver? Future.delayed(Duration(seconds: 3)).then((value){
Navigator.pop(context);
}):print('gameisover');

}

Future<void> introAnim() async{

  Future.delayed(Duration(milliseconds: 800)).then((value) async {
      setState(() {
      timerHeight = 50;
      timerWidth = 75;
      timerRadius = 8;
      timerBorderWidth = 2;
      timerFontSize = 32;

      });
      print('should i game over $questionNum / ${widget.amount}');
     
        if(questionNum + 1 > widget.amount && widget.amount > 0){
                setState(() {
                gameOver = true; 
                });
              print('GAME OVER');
              addPoints();
                Navigator.push(context, PageTransition(
            type: PageTransitionType.rightToLeft,
            child: GameOver(widget.roomNum,players)
          ));

      } 
    
      
      
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
    //_LockedInState().clearLockList();

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
      
            if(!lockList.contains(false) && lockList.length > 0){
          print('ummm');
          timer.cancel();
            setState(() {
            lockList = [false];
            roundOver = true;
            nextQuestion();     
            resetAnim();
          });
       
        }


    

        
         checkLocked();


       print('${questionNum + 1} / ${widget.amount}');
 
            print(_start);
        if (_start < 1) {
          timer.cancel();
            print('ROUND OVER ->');
            setState(() {
            roundOver = true;
            questionNum = questionNum +1;     
           
          });
        
    resetAnim();
      
         
          
        } else {
          setState(() {
          _start = _start - 1;
          });
        }
      },
    ),
  );
}


  Future<List<bool>> checkLocked() async {
    bool temp = false;
    setState(() {
          lockList = [];

    });
    for(int i = 0; i < players.length; i++){
         temp = await DBHandler().isLocked(widget.roomNum, players[i]);
         setState(() {
          lockList.add(temp);    
         });
      
      }
      print(lockList);
      return lockList;
  }




// @override
// void dispose() {
//   _timer.cancel();
//   DBHandler().deleteRoom(widget.roomNum);
//   super.dispose();
// }







  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
          child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyTheme().backgroundColor(),
        body: ListView(
          children: [
              Center(
                child: Stack(
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
              ),
              Center(child: Text('${questionNum + 1} / ${widget.amount}')),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: 
                  
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 20,
                     child: 
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black
                        ),
                        textAlign: TextAlign.center,
                        child: Text(title),
                        
                        
                    ),
                  )
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
              Container(
                height: 160,
                width: 300,
                child: GridView.builder(
         gridDelegate:new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
         itemCount: lockList.length,
         itemBuilder: (BuildContext context, int index) {
         return Padding(
         padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
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
              )
          ],
        ),
      ),
    );
  }

}



