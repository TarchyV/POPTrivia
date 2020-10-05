




//Difficulty 
//Easy
//Medium
//Hard

//EXAMPLE URL
//https://opentdb.com/api.php?amount=10&category=17&difficulty=medium&type=multiple


import 'dart:convert';

import 'package:http/http.dart' as http;

class TriviaHandler {
var categories =[ 
'General Knowledge : 9',
'Books : 10',
'Film : 11',
'Music : 12',
'Musicals & Theatre : 13',
'Television : 14',
'Video Games : 15',
'Board Games : 16',
'Science & Nature : 17',
'Computers : 18',
'Mathematics : 19',
'Mythology : 20',
'Sports : 21',
'Geology : 22',
'History : 23',
'Politics : 24',
'Art : 25',
'Celebrites : 26',
'Animals : 27',
'Vehicles : 28',
'Comics : 29',
'Gadgets : 30',
'Anime/Manga : 31',
'Cartoons : 32' ];

List<String> getCategories(){


return categories;

}



Future<Map<dynamic,dynamic>> createTrivia(int amount, int category, int difficulty) async{

  //IMPORTANT IMPORTANT IMPORTANT IMPORTANT
//ONLY HOST NEEDS TO DO THIS, THEN THE HOST PUSHES IT TO THE DATABASE FOR ALL OTHER PLAYERS TO SEE

String d = 'easy';
switch (difficulty) {
  case 0:
    d = 'easy';
    break;
  case 1:
    d = 'medium';
    break;    
      case 2:
    d = 'hard';
    break;
  default:
}

String url = 'https://opentdb.com/api.php?amount=${amount.toString()}&category=${category.toString()}&difficulty=$d&type=multiple';
print(url);
var response = await http.post(url);

final temp = json.decode(response.body) as Map;
List<dynamic> data = temp['results'];
return data.asMap();
}



}