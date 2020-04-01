//Creates an item from the given string with position and String to represent the icon
class Item{
  PVector position;
  String iconString;
  String localLines[];
  
  Item(String s){
   localLines = split(s, ' ');
    position = new PVector(float (localLines[0]), float (localLines[1]));
    iconString = localLines[2];
  }
  
}
