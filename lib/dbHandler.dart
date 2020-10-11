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
   _ref.child('Rooms').child(roomNum.toString()).child('Players').child(host).update({
    'locked': ''
   });
_ref.child('Rooms').child(roomNum.toString()).child('Players').child(host).update({
    'Score': 0
   });
}
return roomNum;
}

Future<void> addPoints(int roomNum, String name, int points) async {
int score = 0;
await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).once().then((DataSnapshot data){

  var temp = data.value.toString();
      score = int.parse(temp.substring(temp.indexOf('Score: ') + 7, temp.length-1)) + points;
});
await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).update({
'Score': score
});

}


Future<int> getPoints(int roomNum, String name) async {
int points = 0;
await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).once().then((DataSnapshot data){

  var temp = data.value.toString();
      points = int.parse(temp.substring(temp.indexOf('Score: ') + 7, temp.length-1));
});

return points;

}


Future<bool> isLocked(int roomNum, String name) async {

bool isLocked = false;
 await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).child('locked').once().then((DataSnapshot data){
      if(data.value.toString().length > 0){
        isLocked = true;
      }else{
        isLocked = false;
      }

  });
  return isLocked;
}


Future<void> lockIn(int roomNum, String name, String answer) async {
await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).update({

'locked': answer

});

}
Future<void> lockOut(int roomNum, String name) async {
await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).update({

'locked': ''

});
}

void deleteRoom(int roomNum){
   _ref.child('Rooms').child(roomNum.toString()).remove();
}


Future<bool> isCorrect(int roomNum, String name) async {

bool correct = false;
await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).once().then((DataSnapshot data){

  if(data.value.toString().substring(data.value.toString().indexOf('locked: '),  data.value.toString().indexOf(', Score:')).contains('Answer')){
    correct = true;
  }


});

return correct;

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
  try {
    
  } catch (e) {
  }
  await _ref.child('Rooms').child(roomNum.toString()).child('Players').once().then((value) {
    Map<dynamic,dynamic> x = value.value;
    x.forEach((key, value) {
      if(!pList.contains(key)){
        pList.add(key);
      }
    });
  });
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

Future<void> pushTriva(List<String> questions, int roomNum) async {
await _ref.child('Rooms').child(roomNum.toString()).child('Questions').set(questions);



}







}