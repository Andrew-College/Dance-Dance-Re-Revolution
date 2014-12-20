
import java.nio.charset.Charset;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.nio.file.WatchEvent.Kind;
import java.nio.file.WatchEvent.Modifier;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import oscP5.*;//cannot use imports in tabs(https://code.google.com/p/processing/issues/detail?id=459)
import netP5.*;


CONFIG.KEYBINDS KEYBIND_INSTANCE;
CONFIG.paths COMMUNICATIONS_PATHS;
Communications communications = new Communications();

public int segments = 3, blocks = 9, timeoutInterval = 0, maxGraphSize = 0, applicationState = 0, padding = 0;
public long pressTimeout = 0, releaseTimeout = 0;
public Float[] YValues = {};


public float X = 0, Y = 0, progress = 0;

public boolean flipflop = false;

void setup(){
  size(1024,768);
  COMMUNICATIONS_PATHS.SEND.add("/filePath");
  COMMUNICATIONS_PATHS.SEND.add("/keyboardInput");
  COMMUNICATIONS_PATHS.SEND.add("/generateGraph");
  COMMUNICATIONS_PATHS.RECIEVE.add("/recieveMessage");
  COMMUNICATIONS_PATHS.RECIEVE.add("/graphData");
  COMMUNICATIONS_PATHS.RECIEVE.add("/graphSize");
  COMMUNICATIONS_PATHS.RECIEVE.add("/progress");
}

void draw() {  
  background(100);
  //colorMode(HSB, 360,100,100,100);
  switch(applicationState){
    case 0:
      mainUI();
      break;
    case 1:
      gameUI();
    case 2:
      gameUI();
    break;
    default://something tried to set a weird state, go back to menu
      applicationState = 0;
      break;
  }
}

void mouseClicked(){
  switch(applicationState){
    case 0:
        for(int i = 1; i < 5; i++){
          int index = (int) collision(mouseX, mouseY, padding, i);
          switch(index){
            case 1:
              applicationState = 1;
              communications.send(COMMUNICATIONS_PATHS.SEND.get(0),"");
              break;
            case 2:
              applicationState = 2;
              communications.send(COMMUNICATIONS_PATHS.SEND.get(0),"");
              break;
            case 3:
              System.out.println("TODO");
              break;
            case 4:
              exit();
              break;
            default:
              break;
          }
        }
      break;
  }
}

void keyPressed(){
  //System.out.println("key; " + key);
  //System.out.println("keycode; " + keyCode);
  //System.out.println(CONFIG.KEYBINDS.getFromValue(keyCode));
  //communications.send(COMMUNICATIONS_PATHS.SEND.get(0),"");
  if(CONFIG.KEYBINDS.getFromValue(keyCode) != null && (pressTimeout - System.currentTimeMillis()) < 0){
    switch(CONFIG.KEYBINDS.getFromValue(keyCode)){
      case NW:
        KEYBIND_INSTANCE.NW.getColours()[2] = 100;
        break;
      case N:
        KEYBIND_INSTANCE.N.getColours()[2] = 100;
        break;
      case NE:
        KEYBIND_INSTANCE.NE.getColours()[2] = 100;
        break;
      case W:
        KEYBIND_INSTANCE.W.getColours()[2] = 100;
        break;
      case C:
        KEYBIND_INSTANCE.C.getColours()[2] = 100;
        break;
      case E:
        KEYBIND_INSTANCE.E.getColours()[2] = 100;
        break;
      case SW:
        KEYBIND_INSTANCE.SW.getColours()[2] = 100;
        break;
      case S:
        KEYBIND_INSTANCE.S.getColours()[2] = 100;
        break;
      case SE:
        KEYBIND_INSTANCE.SE.getColours()[2] = 100;
        break;
      default:
        System.out.println("Key is not used");
        break;  
    }
    pressTimeout = System.currentTimeMillis() + timeoutInterval;
  }
}

void keyReleased(){
  //System.out.println("key; " + key);
  //System.out.println("keycode; " + keyCode);
  //System.out.println(KEYBINDS.get(keyCode));
  if(CONFIG.KEYBINDS.getFromValue(keyCode) != null && (releaseTimeout-System.currentTimeMillis() <= 0)){
    switch(CONFIG.KEYBINDS.getFromValue(keyCode)){
      case NW:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.NW.getColours()[2] = 50;
        break;
      case N:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.N.getColours()[2] = 50;
        break;
      case NE:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.NE.getColours()[2] = 50;
        break;
      case W:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.W.getColours()[2] = 50;
        break;
      case C:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.C.getColours()[2] = 50;
        break;
      case E:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.E.getColours()[2] = 50;
        break;
      case SW:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.SW.getColours()[2] = 50;
        break;
      case S:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.S.getColours()[2] = 50;
        break;
      case SE:
      //System.out.println(KEYBIND_INSTANCE.getFromValue(keyCode));
        KEYBIND_INSTANCE.SE.getColours()[2] = 50;
        break;
      default:
        System.out.println("Key is not used");
        break;  
    }
    releaseTimeout = System.currentTimeMillis() + timeoutInterval;
  }
  
}

public class Communications implements AutoCloseable{  
  OscP5 OSCP5;
  NetAddress sendLocation;
  
  //define constants
  public final String localhost = "127.0.0.1";
  public final Integer sendPort = 9997, recievePort = 9998;
  
  public Communications(){
    OSCP5 = new OscP5(this,recievePort);
    sendLocation = new NetAddress(localhost,sendPort);
  }
  
  public void send(String path, String data){
    
    //create message to send
    OscMessage sendMessage = new OscMessage(path);
    
    sendMessage.add(data);
    
    OSCP5.send(sendMessage, sendLocation);
  }
  
  //recieve input from port
  public void oscEvent(OscMessage theOscMessage){
    //theOscMessage.printData();
    //check against all values in the recieve enum
    if(theOscMessage.checkAddrPattern(COMMUNICATIONS_PATHS.RECIEVE.pathVal.get(0))){
      theOscMessage.printData();
      return;
    }else if(theOscMessage.checkAddrPattern(COMMUNICATIONS_PATHS.RECIEVE.pathVal.get(1))){
      println("got a file");
      println(System.getProperty("user.dir"));
      println();
      try{
        List<String> lines=Files.readAllLines(Paths.get(sketchPath + "\\" +CONFIG.GRAPH_FILE_NAME), Charset.forName("UTF-8"));
        YValues = new Float[lines.size()];
        int i = -1;
        for(String element: lines){
          YValues[++i] = Float.valueOf(element);
        }
      }catch(Exception e){
        e.printStackTrace();
      }
      /*
      println("1");
      Float[] floatArguments = Arrays.copyOf(theOscMessage.arguments(), theOscMessage.arguments().length, Float[].class);
      println("2");
      YValues = concatenateArrays(YValues,floatArguments);
      println("3");
      */
      println("got a path");
      return;
    }else if(theOscMessage.checkAddrPattern(COMMUNICATIONS_PATHS.RECIEVE.pathVal.get(2))){
      //println(theOscMessage.get(0).intValue());
      maxGraphSize = theOscMessage.get(0).intValue();
      //println(maxGraphSize);
      return;
    }else if(theOscMessage.checkAddrPattern(COMMUNICATIONS_PATHS.RECIEVE.pathVal.get(3))){//gotten progress update
      progress = theOscMessage.get(0).floatValue();
      return;
    }
    System.out.println("path doesnt exist! " + theOscMessage.addrPattern());
  }
  
  public void close() throws Exception {
    // TODO Auto-generated method stub
  }

/*
  public Float[] concatenateArrays(Float[]... adders){
    flipflop = !flipflop;
    Float[] main = {};
    int initialSize = main.length;
    for(Float[] array: adders){
      println("array size" + array.length);
      initialSize += array.length;
    }
    int offset = main.length;
    println("1; " + offset);
    main = Arrays.copyOf(main, initialSize);
    println(main.length);
    for(Float[] array: adders){
      
      println("offset1: " + offset);
      System.arraycopy(array, 0, main, offset, array.length);
      offset += array.length;
      println("offset2: " + offset);
    }
    println("n");
    flipflop = !flipflop;
    return main;
  }
  */
}


/**
*BELOW: Current game drawing states
**/
public void mainUI(){
  color rectColor = color(0);
  color rectHighlight = color(51);
  int collisionIndex = -1;
  String[] menuOptions = {"Play", "Create", "Configure", "Quit"};
  float[] dimens = CONFIG.MENU_RECTANGLE_DIMENSIONS;
  
  X = 100;
  padding = 100;
  fill(150);
  textSize(40);
  waveCharacters(CONFIG.TITLE,100);
  
  stroke(255);
  for(int i = 1; i < 5; i++){
    if(
      collision(
        mouseX, mouseY,
        padding, i
      ) != -1
    ){
      fill(230);
    }else{
      fill(150);
    }

    rect(
    width * dimens[0],
    padding + height * dimens[1] * i,
    width * dimens[2],
    height * dimens[3]
    );
    fill(255);
    text(menuOptions[i-1], (width * .1666666) + 100, i * (height * .125) + 160);
  }
}

public void waveCharacters(String word, float originalY){
  Y+=0.001;
  for(int c = 0; c < word.length(); c++){
    Y+=0.001;
    text(word.charAt(c), X + (32*c), originalY + (sin(Y)*10));
  }
}

public float collision(float posX, float posY, float heightModifier1, float heightModifier2){
  float[] dimens = CONFIG.MENU_RECTANGLE_DIMENSIONS;
//println(posX >= width * dimens[0] && posX <= width * dimens[2]);
//println( posY >= heightModifier1 + height * dimens[1] * heightModifier2 && posY <=  height * dimens[3]);
  return (
  posX >= width * dimens[0] && posX <= width * dimens[2] 
  &&
  posY >= (heightModifier1 + height * dimens[1] * heightModifier2) && posY <=  ((heightModifier1 + height * dimens[1] * heightModifier2))+(height * dimens[3])
  ?heightModifier2:-1);
}


/*
*  GAME INTERFACE - features progress, mat, etc.
*/
public void gameUI(){
  int j = -1, smallHeight = height - 100, smallMiddleHeight = smallHeight + ((height - smallHeight)/2);
  //keyboard squares
  //fill(50);
  for(int i = 0; i < blocks; i++){
      j = (i % 3 == 0? j+1:j);
      //System.out.println(j);
      int[] colours = KEYBIND_INSTANCE.values()[i].getColours();
      fill(colours[0],colours[1],colours[2],colours[3]);
      rect((width/(blocks/segments))*(i%3), (smallHeight/(blocks/segments))*j, (width/segments), (smallHeight/segments));
  }
  fill(153);
  //graph area
  rect(0, smallHeight, width, height);
  stroke(100);
  line(0, smallMiddleHeight, width, smallMiddleHeight);
  stroke(0);
  //println(YValues.length>1 && maxGraphSize > 0);
  
  //if we have something useful, dont bother otherwise
  if(YValues.length>1 && maxGraphSize > 0){
    float previousX = ((1/maxGraphSize)*width);
    float previousY = 
       ((float)smallMiddleHeight + 
       ((YValues[1] == null? 0:YValues[1]) * (smallMiddleHeight - smallHeight)));
    //println("line(0,"+YValues[0]+","+((1/maxGraphSize)*width)+","+YValues[1]+");");
    
    line(0,
    ((float)smallMiddleHeight + 
       ((YValues[0] == null? 0:YValues[0]) * (smallMiddleHeight - smallHeight))),
       ((1/maxGraphSize)*width),
       ((float)smallMiddleHeight + 
       ((YValues[1] == null? 0:YValues[1]) * (smallMiddleHeight - smallHeight))));
    
    for(int i = 3; i < YValues.length; i+=(YValues.length/CONFIG.MAX_DATAPOINTS)){
     line(
       //(((float)i--/maxGraphSize)*width),
       previousX,
       previousY,
       (((float)i/maxGraphSize)*width),
       ((float)smallMiddleHeight + 
       ((YValues[i] == null? 0:YValues[i]) * (smallMiddleHeight - smallHeight)))
     );
     previousX = (((float)++i/maxGraphSize)*width);
     previousY = ((float)smallMiddleHeight + 
       ((YValues[i] == null? 0:YValues[i]) * (smallMiddleHeight - smallHeight)));
     //println("line("+((i--/maxGraphSize)*width)+","+(smallMiddleHeight + YValues[i])+","+((i++/maxGraphSize)*width)+","+(smallMiddleHeight + YValues[i])+");");
    }
    //progress bar
    line(progress*width, smallHeight, progress*width, height);
  }
}

