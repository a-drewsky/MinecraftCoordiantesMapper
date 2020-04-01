//Andy Dembofsky
//28 March 2020
//A Program to plot MineCraft coordinats and display a icon for each
//User has the ability to scroll with the scroll wheel,
//pan by holding right mouse down
//and add markers by clicking right mouse

String[] lines; //Lines read from text file
float maxval; //max value of the minecraft world
String[] coords; //used to read given coords
PVector[] givenCoords; //Vectorizes given coords
float blockDistance; //density of the grid
float iconSize; //the size to display icons relative to zoom level
float iconRez; //the resolution to set icons relative to grid density
float ICONSCALE = 100; //Chosen icon size
Item[] items; //Array of items
ArrayList<PVector[]> gridPoints; //the points of the grid
ArrayList<PVector> marks; //Arraylist to hold placed marks
PVector pan; //pan amount
PVector zoomPan; //zoom amount
//PVector dirPan; //accounts for shift of pan from zoom
float zoom; //zoom amount

//Images
PImage badlands;
PImage base;
PImage flowers;
PImage hut;
PImage ice;
PImage igloo;
PImage jungle;
PImage mansion;
PImage monument;
PImage mooshrooms;
PImage reef;
PImage spawn;
PImage taiga;
PImage tundra;
PImage village;

//Runs once at start
void setup() {
  size(1000, 1000);
  background(255);
  strokeWeight(1);
  stroke(25);
  fill(100);
  tint(255, 200);
  imageMode(CENTER);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);
  noCursor();

  badlands = loadImage("icons/badlands.png");
  base = loadImage("icons/base.png");
  flowers = loadImage("icons/flowers.png");
  hut = loadImage("icons/hut.png");
  ice = loadImage("icons/ice.png");
  igloo = loadImage("icons/igloo.png");
  jungle = loadImage("icons/jungle.png");
  mansion = loadImage("icons/mansion.png");
  monument = loadImage("icons/monument.png");
  mooshrooms = loadImage("icons/mooshrooms.png");
  reef = loadImage("icons/reef.png");
  spawn = loadImage("icons/spawn.png");
  taiga = loadImage("icons/taiga.png");
  tundra = loadImage("icons/tundra.png");
  village = loadImage("icons/village.png");

  pan = new PVector(0, 0);
  zoomPan = new PVector(0, 0);
  //dirPan = new PVector(0, 0);
  gridPoints = new ArrayList<PVector[]>();
  marks = new ArrayList<PVector>();
  lines = loadStrings("coords.txt"); //read text file line by line
  coords=new String[4];
  givenCoords=new PVector[2];

  //populate coords to create grid
  coords = split(lines[0], ' ');
  for (int i=0; i<coords.length-1; i+=2) {
    givenCoords[i/2] = new PVector(int (coords[i]), int (coords[i+1]));
  }

  //calculates block distance
  blockDistance = dist(givenCoords[0].x, givenCoords[0].y, givenCoords[1].x, givenCoords[1].y);

  //initialize items list
  items = new Item[lines.length-1];

  //calculate the max value of the grid (based on the object with furthest coords)
  for (int i=1; i<lines.length; i++) {
    items[i-1]=new Item(lines[i]);
    if (abs(items[i-1].position.x)>maxval) maxval = abs(items[i-1].position.x);
    if (abs(items[i-1].position.y)>maxval) maxval = abs(items[i-1].position.y);
  }

  //Round up maxval to the next blockDistance
  int max = 0;
  while (max<maxval) max+=blockDistance;
  maxval = max;

  //populate grid points
  SetPoints(givenCoords[0]);

  //calculate icon size and resolution
  iconSize = doMapX(blockDistance)/16;
  iconRez = doMapX(blockDistance)/9;

  resizeIcons();
}

//resizes icons to the proper resolution
void resizeIcons() {

  badlands.resize(int(iconRez), int(iconRez));
  base.resize(int(iconRez), int(iconRez));
  flowers.resize(int(iconRez), int(iconRez));
  hut.resize(int(iconRez), int(iconRez));
  ice.resize(int(iconRez), int(iconRez));
  igloo.resize(int(iconRez), int(iconRez));
  jungle.resize(int(iconRez), int(iconRez));
  mansion.resize(int(iconRez), int(iconRez));
  monument.resize(int(iconRez), int(iconRez));
  mooshrooms.resize(int(iconRez), int(iconRez));
  reef.resize(int(iconRez), int(iconRez));
  spawn.resize(int(iconRez), int(iconRez));
  taiga.resize(int(iconRez), int(iconRez));
  tundra.resize(int(iconRez), int(iconRez));
  village.resize(int(iconRez), int(iconRez));
}

//Draw the grid based on list of points
void DrawGrid() {
  stroke(25, 50);
  for (int i=0; i<gridPoints.size(); i++) {
    line(gridPoints.get(i)[0].x, gridPoints.get(i)[0].y, gridPoints.get(i)[1].x, gridPoints.get(i)[1].y);
  }
}

//Creates 4 variables representing the corners of the grid and pushes them to their respective positions then passes them to GetPoints
void SetPoints(PVector p) {
  PVector bl1 = new PVector(p.x, p.y);
  PVector bl2 = new PVector(p.x, p.y);
  PVector br = new PVector(p.x, p.y);
  PVector tl = new PVector(p.x, p.y);

  while (bl1.x>(-1 * maxval) && bl1.y<(maxval)) {
    bl1.x-=blockDistance;
    bl1.y+=blockDistance;
  }
  br = bl1.copy();
  while (br.x<maxval-blockDistance*2) {
    br.x+=blockDistance;
  }
  tl=bl1.copy();
  while (tl.y>(-1 * maxval)-blockDistance) {
    tl.y-=blockDistance;
  }
  bl2 = bl1.copy();
  GetPoints(bl1, bl2, br, tl);
}

//Calculate the position of the screen relative to the minecraft world coords
float doMapX(float x) {
  PVector toPan = new PVector(pan.x+zoomPan.x, pan.y+zoomPan.y);
  return map(x, -maxval, maxval, 0, 1000+zoom)+4+toPan.y; //plus 4 centers the map idk why
}
float doMapY(float y) {
  PVector toPan = new PVector(pan.x+zoomPan.x, pan.y+zoomPan.y);
  return map(y, -maxval, maxval, 0, 1000+zoom)+4+toPan.x; //plus 4 centers the map idk why
}


//Gets the points needed to draw the grid
void GetPoints(PVector bl1, PVector bl2, PVector br, PVector tl) {
  gridPoints.clear();
  PVector[] vecs = {new PVector(doMapX(bl1.x), doMapY(bl1.y)), new PVector(doMapX(br.x+blockDistance), doMapY(br.y))};
  gridPoints.add(vecs);
  while (bl1.y>(-1 * maxval)) {
    bl1.y-=blockDistance; 
    br.y-=blockDistance;
    PVector[] vecs2 = {new PVector(doMapX(bl1.x), doMapY(bl1.y)), new PVector(doMapX(br.x+blockDistance), doMapY(br.y))};
    gridPoints.add(vecs2);
  }

  PVector[] vecs3 = {new PVector(doMapX(bl2.x), doMapY(bl2.y)), new PVector(doMapX(tl.x), doMapY(tl.y+blockDistance))};
  gridPoints.add(vecs3);
  while (bl2.x<maxval-blockDistance) {
    bl2.x+=blockDistance; 
    tl.x+=blockDistance;
    PVector[] vecs4 = {new PVector(doMapX(bl2.x), doMapY(bl2.y)), new PVector(doMapX(tl.x), doMapY(tl.y+blockDistance))};
    gridPoints.add(vecs4);
  }
}

//runs every frame
void draw() {
   
  //Used to Restirct pan distance
  int testX = int((map(500, 0, 1000, -maxval, maxval)-map(pan.y, -500, 500, -maxval, maxval)));
  int testY = int((map(500, 0, 1000, -maxval, maxval)-map(pan.x, -500, 500, -maxval, maxval)));
  testX = int(map(testX, 0, 1000+zoom, 0, 1000));
  testY = int(map(testY, 0, 1000+zoom, 0, 1000));
  
  if (testX<=-maxval) {
    pan.y-=5;
  }
  if (testX>=maxval) {
    pan.y+=5;
  }
  if (testY<=-maxval) {
    pan.x-=5;
  }
  if (testY>=maxval) {
    pan.x+=5;
  }

  //Calculate pan amount
  if (mousePressed) {
    PVector mouseMovement = new PVector(mouseY - pmouseY, mouseX - pmouseX);

    testX = int((map(500, 0, 1000, -maxval, maxval)-map(pan.y, -500, 500, -maxval, maxval)));
    testY = int((map(500, 0, 1000, -maxval, maxval)-map(pan.x, -500, 500, -maxval, maxval)));
    testX = int(map(testX, 0, 1000+zoom, 0, 1000));
    testY = int(map(testY, 0, 1000+zoom, 0, 1000));

    if (testX>-maxval && testX<maxval && testY>-maxval && testY<maxval) {
      pan.x+= mouseMovement.x;
      pan.y+=mouseMovement.y;
    }
  }
  
  //redraw the background
  background(255);

  //Calculate grid points based on pan and zoom
  SetPoints(givenCoords[0]);

  //draw the grid
  DrawGrid();

  //Display icons
  for (Item i : items) {

    if (i.iconString.equals("badlands")) image(badlands, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("base")) image(base, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("flowers")) image(flowers, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("hut")) image(hut, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("ice")) image(ice, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("igloo")) image(igloo, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("jungle")) image(jungle, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("mansion")) image(mansion, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("monument")) image(monument, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("mooshrooms")) image(mooshrooms, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("reef")) image(reef, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("spawn")) image(spawn, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("taiga")) image(taiga, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("tundra")) image(tundra, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
    if (i.iconString.equals("village")) image(village, doMapX(i.position.x), doMapY(i.position.y), iconSize+zoom/ICONSCALE, iconSize+zoom/ICONSCALE);
  }


  //Show mouse postion
  fill(100);
  rect(mouseX+65, mouseY+20, 100, 20);
  fill(200);
  int showX = int((map(mouseX, 0, 1000, -maxval, maxval)-map(pan.y, -500, 500, -maxval, maxval)));
  int showY = int((map(mouseY, 0, 1000, -maxval, maxval)-map(pan.x, -500, 500, -maxval, maxval)));
  showX = int(map(showX, 0, 1000+zoom, 0, 1000));
  showY = int(map(showY, 0, 1000+zoom, 0, 1000));
  textSize(12);
  text("("+ showX + ", " + showY +")", mouseX+65, mouseY+25);

  //Draw croshair
  stroke(25,150);
  line(mouseX-2, mouseY-2, mouseX+8, mouseY+8);
  line(mouseX-2, mouseY+8, mouseX+8, mouseY-2);

  //Shows a target and its coords in the minecraft world for each mark
  for (int i=0; i<marks.size(); i++) {
    fill(200, 100, 100);
    noStroke();
    ellipse(doMapX(marks.get(i).x), doMapY(marks.get(i).y), 5, 5);

    noFill();
    stroke(200, 100, 100);
    ellipse(doMapX(marks.get(i).x), doMapY(marks.get(i).y), 15, 15);
    noStroke();
    fill(100, 150);
    rect(doMapX(marks.get(i).x)+60+(zoom/200), doMapY(marks.get(i).y)+10+(zoom/1000), 85+(zoom/100), 15+(zoom/500));
    fill(200);
    fill(25);
    textSize(9+(zoom/1000));
    text("("+ int(marks.get(i).x) + ", " + int(marks.get(i).y) +")", doMapX(marks.get(i).x)+60+(zoom/200), doMapY(marks.get(i).y)+13+(zoom/700));
  }
}

//Zoom when wheel is scrolled
void mouseWheel(MouseEvent event) {
  if (event.getCount()==-1 && zoom - (event.getCount()*50) < 4000) {
    zoomPan.x += (event.getCount()*25-(sqrt(zoom)/2));
    zoomPan.y += (event.getCount()*25-(sqrt(zoom)/2));
    pan.mult(1+pow(zoom, 1/3)/40);
    zoom -= (event.getCount()*50-sqrt(zoom));
  } else if ( event.getCount()==1) {
    if (zoom - (event.getCount()*50+sqrt(zoom))>0) {
      zoomPan.x += (event.getCount()*25+(sqrt(zoom)/2));
      zoomPan.y += (event.getCount()*25+(sqrt(zoom)/2));
      pan.div(1+pow(zoom, 1/3)/30);
      zoom -= (event.getCount()*50+sqrt(zoom));
    } else {
      zoomPan.x = 0;
      zoomPan.y = 0;
      PVector panLoc = new PVector(new PVector(pan.x+zoomPan.x, pan.y+zoomPan.y).x+(zoom/2), new PVector(pan.x+zoomPan.x, pan.y+zoomPan.y).y+(zoom/2));
      zoom=0;
    }
  }

}

void mouseClicked() {

  int locX = int((map(mouseX, 0, 1000, -maxval, maxval)-map(pan.y, -500, 500, -maxval, maxval)));
  int locY = int((map(mouseY, 0, 1000, -maxval, maxval)-map(pan.x, -500, 500, -maxval, maxval)));
  locX = int(map(locX, 0, 1000+zoom, 0, 1000));
  locY = int(map(locY, 0, 1000+zoom, 0, 1000));

  //Add a mark
  if (mouseButton==LEFT) {
    marks.add(new PVector(locX, locY));
  }
  
  //Remove last mark
  if(mouseButton==RIGHT) {
    if(marks.size()>0)marks.remove(marks.size()-1);
  }
}

//Take a screenshot and place it in the output folder
void keyPressed() {

  if (key == ' ') {
    saveFrame("output/####.png");
  }
}
