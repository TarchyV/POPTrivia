import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'dart:math';


class DBHandler {
DatabaseReference _ref = new FirebaseDatabase().reference();


Future<int> createRoom(String host) async{
var r = new Random();
int roomNum = r.nextInt(999999);
bool unique = await checkNum(roomNum);
if(!unique){
  createRoom(host);
}else{
  _ref.child('Rooms').child(roomNum.toString()).update({
    'host': host
   });
   _ref.child('Rooms').child(roomNum.toString()).child('Players').update({
    host: 0.toString()
   });

}
return roomNum;
}



void fillOptions(int roomNum,String categrory, int difficulty, int amount ){

  _ref.child('Rooms').child(roomNum.toString()).update({
    'Category': categrory,
    'Amount': amount.toString(),
    'Difficulty': difficulty.toString()
   });



}


Future<bool> checkNum(int n) async{
List<String> roomNums = new List();
bool unique = false;
await _ref.child('Rooms').once().then((DataSnapshot data){

Map<dynamic,dynamic> result = data.value;

result.forEach((k,v){

if(!roomNums.contains(k)){
roomNums.add(k);
}
});
});

if(roomNums.contains(n.toString())){
  unique = false;
}else{
  unique = true;
}



return unique;
}


}