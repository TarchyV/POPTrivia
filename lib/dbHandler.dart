
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';


class DBHandler {
DatabaseReference _ref = new FirebaseDatabase().reference();



Future<void> pushTitle(int roomNum, String title) async {

  await _ref.child('Rooms').child(roomNum.toString()).update({
    'Title' : title
   });

}
Future<String> getTitle(int roomNum) async {
  String t = '';
  await _ref.child('Rooms').child(roomNum.toString()).child('Title').once().then((DataSnapshot data){

      t = data.value;

  });
  return t;
}


Future<void> questionNum(int questionNum, int questionLength, int roomNum) async {

  await _ref.child('Rooms').child(roomNum.toString()).update({
    'onQuestion' : questionNum
   });

}
Future<int> getQuestionNum(int roomNum) async {
  int questionNum = 0;
  await _ref.child('Rooms').child(roomNum.toString()).child('onQuestion').once().then((DataSnapshot data){

    questionNum = data.value;

  });
return questionNum;
}



Future<String> joinRoom(String name, String roomNum) async {
String errorText = 'Success';
bool notValid = true;
int n = int.parse(roomNum);
notValid = await checkNum(n);
if(notValid){
  errorText = "Room Number Doesn't exist";
}else{


await getPlayers(n).then((value){
print(value);
print(name);
if(value.length == 8){
errorText = 'Lobby Is Full...';
}else{
if(value.contains(name)){
errorText = 'Name already exists in this lobby';
}else{
errorText = 'Success';
}
}


});


}



return errorText;
}







Future<int> createRoom(String host) async{
var r = new Random();
var timestamp = DateTime.now();
int roomNum = r.nextInt(999999);
bool unique = await checkNum(roomNum);
if(!unique){
  createRoom(host);
}else{
  _ref.child('Rooms').child(roomNum.toString()).update({
    'TS': timestamp.toString(),
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

Future<void> addPlayer(int roomNum, String name) async {

await _ref.child('Rooms').child(roomNum.toString()).child('Players').child(name).update({

'Score':0,
'locked':''

});

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

   await _ref.child('Rooms').child(roomNum.toString()).child('Players').once().then((value) {
    Map<dynamic,dynamic> x = value.value;
    x.forEach((key, value) {

        pList.add(key);
      
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

Future<void> pushTriva(List<String> questions, int roomNum) async {
await _ref.child('Rooms').child(roomNum.toString()).child('Questions').set(questions);



}







}