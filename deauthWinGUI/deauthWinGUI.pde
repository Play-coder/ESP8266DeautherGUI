import processing.serial.*;
import controlP5.*;

Serial port;
ControlP5 GUI;
//-----------------------------------DEBUG MODE--------
boolean debug_mode=false;
//-----------------------------------------------------

char converted;
String field = "";
String[] lines;
String vcp;
int ind=0;
int timer=0;
int loading;
boolean attacking=false;
boolean dataready=false;
boolean itsTimeToScan=false;
boolean startAttacking=false;
boolean startTimedAttack=false;
boolean gettingNames=false;

//--------variabili stations----------
String[] MACs={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
String[] IDs={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
String[] Vendors={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
String[] APs={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
String[] NAMEs={"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
boolean[] selection={false, false, false, false, false, false, false, false, false, 
  false, false, false, false, false, false, false, false, false, false, false};
//-------------fine-------------------

void setup() {
  frameRate(100);
  size(500, 250);
  vcp=findDevice(115200);

  if (debug_mode) {
    println("DEBUG MODE ACTIVE:");
    println("connected to "+ vcp +" port");
  }

  deleteStations();

  GUI = new ControlP5(this);
  GUI.addButton("sendButton").setPosition(215, 10).setSize(75, 20).setLabel("SEND");
  GUI.addTextfield("sendField").setPosition(10, 10).setAutoClear(true).setLabel("");
  GUI.addButton("scanButton").setPosition(215, 30).setSize(75, 20).setLabel("SCAN STATIONS");
  GUI.addButton("up").setPosition(215, 50).setSize(75, 20).setLabel(">>>>");
  GUI.addButton("down").setPosition(215, 70).setSize(75, 20).setLabel("<<<<");
  GUI.addButton("attack").setPosition(215, 90).setSize(75, 20).setLabel("ATTACK");
  GUI.addButton("stopAttack").setPosition(215, 110).setSize(75, 20).setLabel("STOP");
  GUI.addButton("select").setPosition(215, 130).setSize(75, 20).setLabel("SELECT/DESELECT");
  GUI.addButton("clear").setPosition(215, 150).setSize(75, 20).setLabel("CLEAR SELECTION");
  GUI.addButton("timed").setPosition(215, 170).setSize(75, 20).setLabel("Lag Injecting");
  GUI.addButton("savebutton").setPosition(290, 190).setSize(37, 20).setLabel("SAVE");
  GUI.addButton("deletebutton").setPosition(327, 190).setSize(37, 20).setLabel("DELETE");
  GUI.addTextfield("savefield").setPosition(215, 190).setAutoClear(false).setSize(75, 20).setLabel("");
  GUI.addSlider("loading").setPosition(300, 60).setRange(0, 100).setLabel("SCANNING..").hide();
  port.buffer(10000);
}

void draw() {
  background(0);
  drawtext();
  showStations();
  field=GUI.get(Textfield.class, "sendField").getText();

  if (itsTimeToScan) {
    GUI.getController("loading").setValue(timer/16);

    timer++;
    if (timer>=1600) {
      GUI.getController("loading").hide();
      scan();
      timer=0;
    }
  }

  if (gettingNames) {
    GUI.getController("loading").setValue(timer/5);

    timer++;
    if (timer>=500) {
      GUI.getController("loading").hide();
      timer=0;
      getNames();
    }
  }

  if (startTimedAttack) {
    GUI.getController("loading").setValue(timer/3);
    timer++;
    if (timer>300) {
      GUI.getController("loading").hide();
      stopAttack();
      startTimedAttack=false;
      timer=0;
    }
  }
  if (!itsTimeToScan && !gettingNames) {
    if (debug_mode)
      checkForSerial();
    else
      serialFlush();
  }
}

void drawtext() {
  textSize(15);
  fill(#ffffff);
  text("Connected to " + vcp, 10, 50);
  text("Attack:", 300, 25);

  if (attacking) {
    fill(#42f548);//verde
    circle(365, 20, 20);
  } else {
    fill(#f54242);//rosso
    circle(365, 20, 20);
  }
  fill(#ffffff);

  if (IDs!=null) {

    if (selection[ind])
      fill(#f54242);
    else
      fill(#ffffff);

    text("ID: "+IDs[ind], 10, 70);
    fill(#ffffff);

    text("MAC:"+MACs[ind], 10, 90);
    text("Vendor:"+Vendors[ind], 10, 110);
    text(APs[ind], 10, 130);
    text("Name:"+NAMEs[ind], 10, 150);
  }
  if (itsTimeToScan)
    text("Waiting for response...", 300, 50);

  if (gettingNames)
    text("Getting names...", 300, 50);

  if (startTimedAttack)
    text("Running timed Attack " +(5-(timer/100)), 300, 50);
}

void showStations() {
  if (!dataready)
    return;

  deleteStations();

  int i=0;
  while (!lines[i].contains("================")) {
    i++;
  }
  int startIndex=++i;


  while (!lines[i].contains("================")) {
    i++;
  }
  int stopIndex=i;

  int index=0;
  for (int j=startIndex; j<stopIndex; j++) {
    IDs[index]=lines[j].substring(0, 2);
    MACs[index]=lines[j].substring(3, 20);
    Vendors[index]=lines[j].substring(41, 49);
    APs[index]=lines[j].substring(59, 83);
    index++;
  }
  send("show names");
  dataready=false;
  gettingNames=true;
  GUI.getController("loading").show();
}

void getNames() {
  gettingNames=false;
  String string="";
  deleteLines();
  while (port.available()>0) {
    string += (char)port.read();
  }

  if (debug_mode)
    print(string);

  lines=split(string, "\n");
  int i=0;
  int startIndex=0;
  try {
    while (!lines[i].contains("================")) {
      i++;
    }
    startIndex=++i;

    while (!lines[i].contains("================")) {
      i++;
    }

    int stopIndex=i;

    for (int j=startIndex; j<stopIndex; j++) {
      for (int n=0; n<=19; n++) {
        if (MACs[n].equals(lines[j].substring(3, 20))) {
          NAMEs[n]=lines[j].substring(30, 40);
        }
      }
    }
  }
  catch(Exception e) {
  }
}

void deleteStations() {
  if (IDs==null)
    return;

  for (int i=0; i<20; i++) {
    IDs[i]=" "+String.valueOf(i);
    MACs[i]="##:##:##:##:##:##";
    Vendors[i]="None";
    APs[i]="AP:None";
    NAMEs[i]="";
  }
}

public void saveName() {
  String name=GUI.get(Textfield.class, "savefield").getText();
  if (debug_mode)
    println(name);

  NAMEs[ind]=name;
  send("add name "+name+" -st "+ind);
}

public void deleteName() {
  if (NAMEs[ind]=="")
    return;

  send("remove -n "+NAMEs[ind]);
  NAMEs[ind]="";
}

public void savebutton() {
  if (frameCount<100)
    return;

  saveName();
}

public void deletebutton() {
  if (frameCount<100)
    return;

  deleteName();
}


public void sendButton() {
  if (frameCount<100)
    return;

  send(field);
}

public void attack() {
  if (frameCount<100 || timer!=0)
    return;

  String toSend="deselect";

  for (int i=0; i<19; i++) {
    if (selection[i]) 
      if (NAMEs[i]=="")
        toSend+=";;select -st "+i;
      else
        toSend+=";;select names "+NAMEs[i];
  }

  toSend+=";;attack deauth nooutput";

  send(toSend);

  attacking=true;
}

public void timed() {
  startTimedAttack=true;
  GUI.getController("loading").show();
  attack();
}

public void stopAttack() {
  if (frameCount<100)
    return;
  attacking=false;
  send("stop");
}

public void clear() {
  if (frameCount<100)
    return;
  for (int i=0; i<20; i++) {
    selection[i]=false;
  }
}

public void select() {
  if (frameCount<100)
    return;

  selection[ind]=!selection[ind];
}

public void scanButton() {
  if (frameCount<100||timer!=0)
    return;

  GUI.getController("loading").show();
  itsTimeToScan=true;
  send("load -n;;scan -st");
}

public void up() {
  if (frameCount>100 && ind<19)
    ind++;
}

public void down() {
  if (frameCount>100 && ind>0)
    ind--;
}

public void sendField(String text) {
  if (frameCount>100)
    send(text);
}

public void send(String text) {
  if (text.length()==0)
    return;

  try {
    port.write(text);
    if (debug_mode)
      println("invio: "+text);
  }
  catch(Exception e) {
    if (debug_mode)
      println("unable to send, is the device probably being disconnected?");
  }
}

void checkForSerial() {
  if ( port.available() > 0) {
    converted = (char) port.read();
    print(converted);
  }
}

String findDevice(int baud) {
  int c=Serial.list().length;
  c--;
  boolean done=false;

  if (debug_mode)
    printArray(Serial.list());

  while (c>=0 && !done) {
    try {
      port = new Serial(this, Serial.list()[c], baud);
      done=true;
    }
    catch(Exception e) {
      done=false;
      c--;
    }
  }

  if (c<0)
    return "none";
  else
    return Serial.list()[c];
}

public void scan() {
  String string="";
  deleteLines();

  while (port.available()>0) {
    string += (char)port.read();
  }
  
  if (debug_mode)
    print(string);

  lines=split(string, "\n");
  dataready=true;
  itsTimeToScan=false;
}

void deleteLines() {
  if (lines==null)
    return;

  for (int i=0; i<lines.length; i++) {
    lines[i]="";
  }
}

void serialFlush() {
  while (port.available()>0) {
    port.read();
  }
}
