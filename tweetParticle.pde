class tweetParticle {

  //data
  Timer tempTimer;

  PVector location; 
  PVector velocity;
  PVector acceleration;
  PVector offset;
  PVector previousVelocity;
  PVector previousAcceleration;

  PVector initialVelocity;
  PVector initialAcceleration;

  boolean shouldConnect;
  boolean inTheZone;

  boolean justSpawned;
  Timer spawnTimer;
  
  float rate;

  float change; //offset value to change noise (for movement)
  float selector;

  boolean displayHash;

  boolean infected; //use this to change the color of the tweet once it's infected

    boolean isAcell;
  boolean isAsmallCell;
  boolean isAmediumCell;

  float h, i, j;
  color normal;
  color recent;
  color grabbed;

  int infectionCount;


  color particleColour;
  color textColour;

  String commonHashtag;

  float xOffset, yOffset;
  float deltaX, deltaY;
  boolean isRecent;
  boolean beingHeld;
  int opacity;
  float lifespan;
  float diam;
  String tweetID; //create a long variable to store the  tweets unique ID
  int retweetCount; //int variable to store how many times tweet has been retweeted

  float mass;

  int category;

  JSONObject json; //the external JSONObject that will be used to import data
  int numberInArray; //determines which particle it is in the external array
  StringList hashys;
  //String hashtagArray;
  String userID; //stores the user's id
  String tweet; //stores the text comprising the user's tweet

    //constructor

  //create a tweet particle using parameters of the external JSON data and position in
  //the external arraylist, as well as starting x and y positions, along with a boolean to determine
  //if the tweet is one of the most recent imports (used to colour it)
  tweetParticle(JSONObject _json, int _nums, PVector l, boolean b) {

    json = _json; //name of external JSON object passed as parameter
    location = l.get();
    numberInArray = _nums; //position in external array list passed as parameter
    isRecent = checkIfRecent(b); //boolean to check if it's recent

    tempTimer = new Timer(15000); //timer sets how long a tweet remains "recent"
    spawnTimer = new Timer(20000);
    particleColour = color(0, 0, 0);

    change = random(-0.15, 0.15);
    rate = random(0.02,0.04);
    
    commonHashtag = "";

    justSpawned = true;

    infectionCount = 0;

    isAcell = false;
    isAsmallCell = false;
    isAmediumCell = false;
    displayHash = false;

    initialAcceleration = new PVector(0, 0);
    initialVelocity = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));

    acceleration = new PVector(random(-0.1, 0.1), random(-0.1, 0.1));
    velocity = new PVector(random(-0.1, 0.1), random(-0.1, 0.1));
    offset = new PVector(random(100), random(100));
    previousVelocity = new PVector();
    previousAcceleration = new PVector();

    beingHeld = false;
    inTheZone = false;

    xOffset = random(30);
    yOffset = random(30);


    tweet = getTweetText();
    userID = getUserID();
    hashys = getHashTags();
    tweetID = getTweetID();
    retweetCount = getRetweetCount();

    selector = random(0, 100);

    if (selector < 3) {
      infected = true;
    } else {
      infected = false;
    }


    if (retweetCount < 10) {
      diam = random(6, 8);
      category = 1;
    } else if (retweetCount > 10 && retweetCount < 100) {
      diam = random(8, 12);
      category = 2;
    } else if (retweetCount > 100 && retweetCount < 1000) {
      diam = random(12, 16);
      category = 3;
    } else if (retweetCount > 1000 && retweetCount < 3000) {
      category = 4;
      diam = random(16, 20);
    } else if (retweetCount > 3000){
      category = 5;
      diam = random(20,24);
    }


    mass = map(retweetCount, 0, 5000, 0.5, 1.3);
  } //end of constructor

  //--------------------------update()-----------------

  //methods
  void update() {

    if (inTheZone == true) {
      velocity.mult(0);
      acceleration.mult(0);
    } else {
      if (justSpawned == true) {
        initialVelocity.add(initialAcceleration);
        location.add(initialVelocity);
        initialAcceleration.mult(0);
      } else {
        velocity.add(acceleration);
        location.add(velocity);

        // acceleration.x = map(noise(offset.x), 0, 1, -.0001, .0001);
        // acceleration.y = map(noise(offset.y), 0, 1, -.0001, .0001);
        acceleration.x = random(-0.0005, 0.0005);
        acceleration.y = random(-0.0005, 0.0005);
        offset.x += change;
        offset.y += change;
        acceleration.mult(0);


        //  lifespan -= 0.0;
      }
    }
  }// end of update()

  //--------------------------display()----------------------

  void display() {
    //if the tweet is part of the most recently imported set, set fill to red
    color c = determineColour();
    if (isRecent == true) {
      noStroke();
      fill(200,65,95);
      textAlign(LEFT);
      textSize(14);
      text(userID, location.x + selectionRange, location.y+5);
    } else {
      if (infected == true) {
        stroke(350, 100, 93,40);
        fill(350, 100, 93, 90);
      } else {
        stroke(150, 170, 160, 40);
        fill(150, 170, 160, 90);
      }
    }
    if (beingHeld == true) {
      location.x = handX;
      location.y = handY;
      displayHashTag();
    }


    if (category == 1) {
      noFill();
      ellipse(location.x, location.y, diam, diam);
      drawCell(c, location, 2,rate);
    } else if (category == 2) {
      noFill();
      ellipse(location.x, location.y, diam, diam);
      drawCell(c, location, 5,rate);
    } else if (category == 3) {
      noFill();
      ellipse(location.x, location.y, diam, diam);
      drawCell(c, location, 7,rate);
    } else if (category == 4) {
      noFill();
      ellipse(location.x, location.y, diam, diam);
      drawCell(c, location, 10,rate);
    } else if (category == 5){
            noFill();
      ellipse(location.x, location.y, diam, diam);
      drawCell(c, location, 13,rate);
    }


    if (tempTimer.isFinished()) {
      isRecent = false;
    }
  }//end of display()


  //-----------------------boundaryDetection()----------------

  //Check to see whether a circle is going to go out of the bounds you set and make sure it doesn't
  void boundaryDetection(int posx, int posy, int screenWidth, int screenHeight) {

    if (location.x>screenWidth) {
      location.x = posx;
    }
    if (location.x<posx) {
      location.x=screenWidth;
    }
    if (location.y>screenHeight) {
      location.y=posy;
    }
    if (location.y<posy) {
      location.y=screenHeight;
    }
  }

  //---------------------checkProximity()-----------------

  boolean checkProximity(float mx, float my) {
    float d = dist(location.x, location.y, mx, my);
    if (d < selectionRange) {
      return true;
    } else {
      return false;
    }
  }

  //--------------------------getTweetText()----------------

  String getTweetText() {
    String tweetText = json.getJSONArray("statuses").getJSONObject(numberInArray).getString("text");
    //  println(tweetText);
    return tweetText;
  }

  //---------------------------getUserID()------------------

  String getUserID() {
    //statuses > user > screen_name (location of the user name)
    String userID = "@" + json.getJSONArray("statuses").getJSONObject(numberInArray).getJSONObject("user").getString("screen_name");
    //println(userID);
    return userID;
  }

  //-------------------------getHashTags()---------------------

  StringList getHashTags() {
    //statuses > entities > hashtags > text (location of the hashtags it contains)
    JSONArray hashtags  = json.getJSONArray("statuses").getJSONObject(numberInArray).getJSONObject("entities").getJSONArray("hashtags");
    //    JSONOBject
    //int count = hashtags.size();
    //println(count);
    StringList tempHashtags = new StringList();
    for (int i = 0; i < hashtags.size (); i++) {
      String tempString = hashtags.getJSONObject(i).getString("text");
      tempHashtags.append(tempString);
    }
    tempHashtags.lower(); //make every string lower case
    for (int i = 0; i < tempHashtags.size (); i++) {
      String toCheck = tempHashtags.get(i);
      //check to see if the element in the StringList is "ebola", if
      //so, remove it
      if (toCheck.equals("ebola")) {
        tempHashtags.remove(i);
      }
    }
    // println(tempHashtags);
    return tempHashtags;
  }

  //-----------------------isWithinReach-------------------

  //this function returns true if the particle is within the selection range of the mouse -
  //determined by passing in the mouse's X and Y positions and the the value for the mouse's
  //selection range
  boolean isWithinReach(float mx, float my, float rad) {
    float d = dist(location.x, location.y, mx, my);
    if (d < rad) {
      return true;
    } else {
      return false;
    }
  }


  //--------------------------checkIfRecent()---------------
  //this function returns true if the particle was part of the most recent set to be imported,
  //which is determined by passing in the parameter of true or false, depending on whether the
  //particle is created by the retrieveInitialTweets() or retrieveRecentTweets()
  boolean checkIfRecent(boolean b) {
    if (b ==true) {
      return true;
    } else {
      return false;
    }
  }


  //--------------------------getTweetID()---------------------

  String getTweetID() {
    //statuses > user > screen_name (location of the user name)
    String tweetID = json.getJSONArray("statuses").getJSONObject(numberInArray).getString("id_str");
    // println(tweetID);
    return tweetID;
  } //end of getTweetID();

  //-----------------------------getRetweetCount()-----------------

  int getRetweetCount() {
    //statuses > user > screen_name (location of the user name)
    int retweetCount = json.getJSONArray("statuses").getJSONObject(numberInArray).getInt("retweet_count");
    // println(retweetCount);
    return retweetCount;
  } //end of getTweetID();

  //-----------------------------applyForce()--------------

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  //---------------------------------attract()--------------------
  PVector attract(tweetParticle p) {

    PVector force = PVector.sub(location, p.location);             // Calculate direction of force
    float distance = force.mag();                                 // Distance between objects
    distance = constrain(distance, 5.0, 25.0);                             // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize();                                            // Normalize vector (distance doesn't matter here, we just want this vector for direction

    float strength = (g * mass * p.mass) / (distance * distance);
    // Calculate gravitional force magnitude
    force.mult(-strength);                                         // Get force vector --> magnitude * direction
    return force;
  }

  //---------------------------------repel()--------------------

  PVector repel(tweetParticle p) {
    PVector force = PVector.sub(location, p.location);             // Calculate direction of force
    float distance = force.mag();                                 // Distance between objects
    distance = constrain(distance, 5.0, 25.0);                             // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize();                                            // Normalize vector (distance doesn't matter here, we just want this vector for direction

    float strength = (g * mass * p.mass) / (distance * distance);
    strength = constrain(strength, 0, 0.00001);
    // Calculate force magnitude
    force.mult(strength);                                         // Get force vector --> magnitude * direction
    return force;
  }

  //----------------------------------drawConnection()-------------------

  //if the boolean checkForConnection() returns true, then a visual connection
  //is drawn between two particles

  void drawConnection(tweetParticle a) {
    color c = determineColour();
    float xoff = random(-5, 5);
    float yoff = random(-5, 5);
    stroke(c);
    strokeWeight(1);
    line(location.x, location.y, a.location.x, a.location.y);
    strokeWeight(0.8);
    stroke(c);
    line(location.x + xoff, location.y + yoff, a.location.x - xoff, a.location.y - yoff);
    strokeWeight(0.5);
    stroke(c);
    line(location.x + xoff, location.y + yoff, a.location.x - xoff, a.location.y - yoff);
    strokeWeight(0.5);
    stroke(c);
    line(location.x - xoff, location.y - yoff, a.location.x - xoff, a.location.y - yoff);
  }

  //-----------------------checkForConnection()------------------------------

  //this function checks two particles against each other, if they share a hashtag
  //the boolean will return true, then a connection can be made
  boolean checkForConnection(tweetParticle p2) {
    StringList s1 = hashys;
    StringList s2 = p2.hashys;
    shouldConnect = false;

    for (int i = 0; i < s1.size (); i++) {
      String stringy1 = s1.get(i);
      // if (stringy1.equals("ebola") == false){
      for (int j = 0; j < s2.size (); j++) {
        String stringy2 = s2.get(j);
        if (stringy1.equals(stringy2)) {
          commonHashtag = stringy1;
          displayHash = true;
          shouldConnect = true;
        } else {
          shouldConnect = false;
          displayHash = false;
        }
      }
      //}
    }
    if (shouldConnect) {
      return true;
    } else {
      return false;
    }
  }

  //-------------------------determineColour()-----------

  color determineColour() {
    noStroke();
    if (isRecent == true) {
      particleColour = color(200,65,95,90);
      textColour = color(200, 70, 95);
    } else if (beingHeld == true) {
      particleColour = color(100,100,100,90);
      textColour = color(100,100,100,90);
    } else if (infected == false) {
      particleColour = color(100, 0, 100, 90);
    } else if (infected == true) {
      particleColour = color(350, 100, 93, 90);
      textColour = color(350, 100, 93, 90);
    }
    return particleColour;
  }

  //---------------------------drawCell()-----------------------------


  void drawCell(color c, PVector tempVec, int size,float rate) {
    fill(c);
    strokeWeight(1);
    pushMatrix();
    translate(tempVec.x, tempVec.y);
    beginShape();
    for (i=0; i<2*PI; i+=PI/64) {
      if (i > 6.2) {
        j = 0;
      } else {
        j = i;
      }
      vertex((size+8*noise(j, h))*cos(j), (size+8*noise(j, h))*sin(j));
    }
    endShape();
    h+=rate;
    popMatrix();
    noFill();
  }
  //---------------------checkSpawnTimer()------------------------------

  void checkSpawnTimer() {
    if (spawnTimer.isFinished()) {
      justSpawned = false;
    }
  }

  // ---------------------infectCell()----------------------------------

  void checkForInfection(tweetParticle p) {
    if (justSpawned == false && infectionCount < 5) {
      float d = dist(location.x, location.y, p.location.x, p.location.y);
      float r = random(0, 500);
      if (p.infected == true && d < 10 && r < 10) {
        stroke(360, 0, 100);
        line(location.x, location.y, p.location.x, p.location.y);
        infected = true;
        infectionCount++;
        fill(100, 100, 100, 90);
        ellipse(p.location.x, p.location.y, 20, 20);
      }
    }
  }

  //----------------------------------displayHashtag()-----------------------------

  void displayHashTag() {
    fill(100, 100, 100);
    textSize(14);
    if (commonHashtag != ""){
    text("#" + commonHashtag, location.x+selectionRange, location.y-10);
    }
  }

  void displayFullTweet(PFont f) {
    if (inTheZone == true) {
      textFont(f2);
      textAlign(LEFT, CENTER);
      //stroke(360, 0, 100);
      fill(350, 0, 93);
      text(tweet, dropZone.x + dropZoneRadius + 30, dropZone.y-dropZoneRadius, width/2-150, dropZoneRadius*2);
      textAlign(CENTER);
      if(commonHashtag != ""){
      text("#" + commonHashtag, dropZone.x, dropZone.y - dropZoneRadius-10);
      }
      text(userID, dropZone.x, dropZone.y + dropZoneRadius + 20);
      textAlign(RIGHT, CENTER);
      text("Number of retweets: " + retweetCount, dropZone.x - dropZoneRadius - 30, dropZone.y);
      //text("Country of origin: ", dropZone.x - dropZoneRadius - 30, dropZone.y + 30);
    }
  }

  void avoidTheZone() {
    float d = dist(location.x, location.y, dropZone.x, dropZone.y);
    if (d < dropZoneRadius+5) {
      velocity.mult(-1);
    }
  }
} //end of class
