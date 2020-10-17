import 'package:page_transition/page_transition.dart';

import '../dbHandler.dart';
import '../main.dart';
import '../my_theme.dart';
import 'package:flutter/material.dart';
class GameOver extends StatefulWidget {
  final int roomNum;
  final List<String> players;

  GameOver(this.roomNum, this.players);

  _GameOverState createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {


    @override
  void initState() {
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
                  MyTheme().button('End Game', (){
                         Navigator.push(context, PageTransition(
                        type: PageTransitionType.scale,
                        child: MyApp()
                      ));
                  })
           ],
         ),
       ),
       
     
    );
  }
}