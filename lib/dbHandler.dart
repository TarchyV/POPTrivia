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

Future<String> getCategory(int roomNum) async{
  String c = '';
await _ref.child('Rooms').child(roomNum.toString()).child('Category').once().then((value) {
  c = value.value;
});
return c;
}
Future<String> getAmount(int roomNum) async{
  String a = '';
await _ref.child('Rooms').child(roomNum.toString()).child('Amount').once().then((value) {
  a = value.value;
});
return a;
}
Future<String> getDifficulty(int roomNum) async{
  String d = '';
await _ref.child('Rooms').child(roomNum.toString()).child('Difficulty').once().then((value) {
  d = value.value;
});
return d;
}

Future<List<String>> getPlayers(int roomNum) async{
  List<String> pList = new List();
  await _ref.child('Rooms').child(roomNum.toString()).child('Players').once().then((value) {
    Map<dynamic,dynamic> x = value.value;
    x.forEach((key, value) {
      if(!pList.contains(key)){
        pList.add(key);
      }
    });
  });
  print(pList);
  return pList;
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