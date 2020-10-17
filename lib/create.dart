import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poptrivia/my_theme.dart';
import 'package:poptrivia/dbHandler.dart';
import 'package:poptrivia/trivaHandler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:page_transition/page_transition.dart';

import 'dbHandler.dart';
import 'game/game.dart';
import 'my_theme.dart';


class CreatePage extends StatefulWidget{
  final String hostName;
  CreatePage(this.hostName);
  @override
  State<StatefulWidget> createState() => _CreatePage();



}

class _CreatePage extends State<CreatePage>{




int roomNum = 0;
  @override
  void initState() {

    super.initState();
    
  }
  

  Future<int> _createRoom() async{
  if(roomNum ==0){
  roomNum = await DBHandler().createRoom(widget.hostName);
  }
  return roomNum;
  }

  Future<void> _delRoom(int roomnum) async{
  DBHandler().deleteRoom(roomNum);
  }

@override
void dispose() { 
  _delRoom(roomNum);
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyTheme().backgroundColor(),
        appBar: AppBar(
          backgroundColor: MyTheme().backgroundColor(),
          centerTitle: true,
          title: MyTheme().title('Create a Game!',22, false, false),
        ),
        body: Center(
          child: Column(
            children: [
              FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return MyTheme().title('#...', 62, true,false
                );
                    }
                    return  Container(
                width: 280,
                child: MyTheme().title('#$roomNum', 62, true,false
                ));

               },
               future: _createRoom(),
               ),
             
                Text('Share This Code With Your Friends!'),
                  FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Container();
                      }

                      return CreateOptions(widget.hostName, roomNum);

                   },
                   
                   future: Future.delayed(Duration(milliseconds: 400)),
                   )




            ],
          ),
        ),
    );
  }

}

class CreateOptions extends StatefulWidget{
  final String hostName;
  final int roomNum;
  CreateOptions(this.hostName, this.roomNum);
  @override
  State<StatefulWidget> createState() => _CreateOptions();


}

class _CreateOptions extends State<CreateOptions>{
  bool selected = false;
  String category = '';
  int difficulty = 0;
  double amount  = 10;
  List<String> players = new List();
  //0 = Easy
  //1 = Medium
  //2 = Hard

@override
  void initState() {
    pushOptions();
    super.initState();
  }

  void pushOptions(){
      DBHandler().fillOptions(widget.roomNum, category, difficulty, amount.toInt());
  }


void _startGame(){

if(category.length < 2){

}else{
 Navigator.push(context, PageTransition(
        type: PageTransitionType.rightToLeft,
        child: Game(widget.roomNum, true, widget.hostName, amount.toInt())
      ));
}
}


  @override
  Widget build(BuildContext context) {
    return Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: 
                  
                  Column(
                    children: [
                      Text('Pick a Category!'),
               !selected? Padding(
                 padding: const EdgeInsets.symmetric(vertical:12.0),
                 child: Container(
                      height: 60,
                      decoration: new BoxDecoration(
                        border: Border(
                          top: BorderSide(
                          color: Colors.grey[800],
                          width: 2
                          ),
                          bottom:  BorderSide(
                          color: Colors.grey[800],
                          width: 2
                          ),
                        
                        )
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: TriviaHandler().categories.length,
                        itemBuilder: (BuildContext context, int index) { 
                          Color c = MyTheme().titleTextColor();
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                  onTap: (){
                                     setState(() {
                                      category =  TriviaHandler().categories[index];
                                      selected = true;
                                      pushOptions();
                                     });
                                  },
                                  child: Container(
                                  height: 20,
                                  width: 125,
                                  decoration: new BoxDecoration(
                                    color: c,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Center(child: Text(TriviaHandler().categories[index].substring(0,TriviaHandler().categories[index].indexOf(':')-1 ))),
                                ),
                              ),
                            );

                         },

                      ),
                    ),
               ): Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Center(child: MyTheme().title(category.substring(0, category.indexOf(':')-1), 28, false, true)),
                    IconButton(
                      icon: Icon(Icons.cancel,
                      size: 18,
                      ),
                      onPressed: (){
                        setState(() {
                         selected = false; 
                         
                        });
                      },
                    )
                  ],),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: (){
                                  setState(() {
                                   difficulty = 0; 
                                   pushOptions();
                                  });
                                },
                                child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: 50,
                                width: 80,
                                decoration: new BoxDecoration(
                                  color: MyTheme().titleTextColor(),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                  color: difficulty==0?Colors.black: Colors.transparent,
                                  width: difficulty==0? 3:0
                                  )
                                ),
                                child: Center(child: 
                                Text('Easy',
                                style: GoogleFonts.anton(

                                ),
                                )),
                              ),
                            ),
                          ),
                           Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: (){
                                  setState(() {
                                   difficulty = 1; 
                                   pushOptions();
                                  });
                                },
                                child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: 50,
                                width: 80,
                                decoration: new BoxDecoration(
                                  color: MyTheme().titleTextColor(),
                                  borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                    color: difficulty==1?Colors.black: Colors.transparent,
                                    width: difficulty==1? 3:0
                                  )
                                ),
                                child: Center(child: 
                                Text('Medium',
                                style: GoogleFonts.anton(

                                ),
                                )),
                              ),
                            ),
                          ),
                           Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: (){
                                  setState(() {
                                   difficulty = 2; 
                                   pushOptions();
                                  });
                                },
                                child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: 50,
                                width: 80,
                                decoration: new BoxDecoration(
                                  color: MyTheme().titleTextColor(),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: difficulty==2?Colors.black: Colors.transparent,
                                    width: difficulty==2? 3:0
                                  )
                                ),
                                child: Center(child: 
                                Text('Hard',
                                style: GoogleFonts.anton(
                                ),
                                )),
                              ),
                            ),
                          )
                      ],
                    ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text('$amount Questions'
                          ),
                        ),
                        Slider(
                          min: 5,
                          max: 25,
                          divisions: 20,
                          inactiveColor: Colors.grey[800],
                          activeColor: MyTheme().titleTextColor(),
                          onChanged:
                           (double value) { 
                             setState(() {
                              amount=value; 
                              pushOptions();
                             });
                            },
                          value: amount,
                        ),
                    PlayersWaiting(widget.roomNum),

                            Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: InkWell(
                                onTap: (){
                                  //START GAME
                                  _startGame();
                                },
                                child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: 40,
                                width: 150,
                                decoration: new BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                    color: MyTheme().titleTextColor(),
                                    width: 2
                                  )
                                ),
                                child: Center(child: 
                                Text('Start',
                                style: GoogleFonts.anton(
                                  color: MyTheme().titleTextColor(),
                                  fontSize: 24,
                                   shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1,2)
                                  )
                                        ] 
                                ),
                                )),
                              ),
                            ),
                          ),

                    ],
                  )
                );
  }
}

class PlayersWaiting extends StatefulWidget{
  final int roomNum;
  PlayersWaiting(this.roomNum);
  @override
  State<StatefulWidget> createState() => _PlayersWaiting();

}

class _PlayersWaiting extends State<PlayersWaiting>{
  DatabaseReference _ref = new FirebaseDatabase().reference();

List<String> players = new List();
@override
  void initState() {
    getPlayers();
    _ref.child('Rooms').child(widget.roomNum.toString()).child('Players').onChildAdded.listen((event) {
      getPlayers();
    });
    super.initState();
  }


  Future<List<String>> getPlayers() async{
        setState(() async {
                  players= await DBHandler().getPlayers(widget.roomNum);

        });
        setState(() {
          
        });
    
    return players;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        height: 85,
        width: 400,
      decoration: BoxDecoration(
      ),
      child: Column(
        children: [
          Text('${players.length}/8 Players!'),
          FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
            if(snapshot.connectionState == ConnectionState.waiting){
              return Container();
            }
            return Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: players.length,
              itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: 150,
                  decoration: new BoxDecoration(
                    color: MyTheme().titleTextColor(),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Center(child: Text('${players[index]}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.abel(

                  ),
                  
                  )),
                ),
              );
            }),
          );
           },
           future: getPlayers(),
           )
         

        ],
      ),
    );
  }

}