import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:poptrivia/dbHandler.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:animate_do/animate_do.dart';

import 'dbHandler.dart';
import 'dbHandler.dart';
import 'my_theme.dart';
import 'my_theme.dart';
import 'trivaHandler.dart';
import 'trivaHandler.dart';

class Game extends StatefulWidget{
  final int roomNum;
  final bool host;
  Game(this.roomNum, this.host);
  @override
  State<StatefulWidget> createState() => _Game();

}

class _Game extends State<Game>{
  DatabaseReference _ref = new FirebaseDatabase().reference();

  @override
  void initState() {
    if(widget.host){

      getTrivia();
      introAnim();

    }else{

      introAnim();

    }

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

Future<void> getTrivia() async{
  
String category = await DBHandler().getCategory(widget.roomNum);
String amount = await DBHandler().getAmount(widget.roomNum);
String difficulty = await DBHandler().getDifficulty(widget.roomNum);
questions = await TriviaHandler().createTrivia(int.parse(amount), int.parse(category.substring(category.indexOf(':') + 1)), int.parse(difficulty));
splitData(questions[questionNum]);

}

String title = '';
String answer = '';
List<String> questionList = new List(); 
void splitData(dynamic qPack){
String q = qPack.toString();
print(q);
title = q.substring(q.indexOf('question: ') + 9, q.indexOf(', correct_answer'));

print('=========');
print(title);
print('=========');
setState(() {
answer = q.substring(q.indexOf('correct_answer: ') + 16, q.indexOf(', incorrect'));
questionList = q.substring(q.indexOf('[') + 1, q.indexOf(']')).split(',');
questionList.add('Answer:'+answer);
});
DBHandler().pushTriva(questionList, widget.roomNum);

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

Future<void> resetAnim() async{
  Future.delayed(Duration(milliseconds: 800)).then((value) {
      setState(() {
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
        if (_start < 1) {
          timer.cancel();
          if(questionNum < questions.length){
            setState(() {
            roundOver = true;
            questionNum = questionNum +1;
            resetAnim();
          });
          }else{
            //GAME IS OVER!!
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


@override
void dispose() {
  _timer.cancel();
  super.dispose();
}
bool correct = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
          child: Scaffold(
        
        backgroundColor: MyTheme().backgroundColor(),
        body: Center(
          child: Column(
            children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 35),
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
                    )
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
                Container(
                  height: 360,
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
                              setState(() {
                               questionList[index] = 'Correct!';
                               correct = true;
                              });
                              
                             
                            }else{
                              print('Incorrect!');
                                setState(() {
                               questionList[index] = '-X-';
                              });

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
                              questionList[index].substring(6):questionList[index],
                            style: GoogleFonts.anton(
                              color: Colors.grey[800]
                            ),
                            textAlign: TextAlign.center,
                            )),
                          )
                        ),
                      ): Container();
                    },


                  ),
                )
            ],
          )
        ),
      ),
    );
  }

}

