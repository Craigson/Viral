//extra features:
//object moving along drawn vector lines
//use like a pipette/ dropper to grab

//---------------------------------------------------------------------

//import necessary libraries
import de.voidplus.leapmotion.*;
import development.*;
import java.util.Date;
import com.temboo.core.*;
import com.temboo.Library.Twitter.Search.*;

PShape shape;
PShape twitter;
PShape ebola;
PShape handOpen;
PShape handPinched;
PShape micro;

LeapMotion leap;
PVector handPos;
float pinchValue = 0;
boolean pinched = false;
float handX, handY;

boolean zoneIsOccupied = false;

int dropZoneRadius = 70;
float x, y;
String initialCount = "100"; //a string as opposed to an integer
float g = 1.2;
boolean keyHasBeenPressed = false; //just used this to stop the particles 
PFont f; //create PFont object
int selectionRange = 30; //set cursor selection range (radius of the circle)
Timer timer = new Timer(30000); //create a timer to import new tweets every x-milliseconds
Timer textTimer = new Timer(15000); //create timer that dicates how long new tweet user IDs are displayed for
Timer tweetTimer = new Timer(2900);  //Timer for intervals between adding new tweets
Timer timer2 = new Timer (15000);
boolean loading = true; //create a boolean variable for animation during loading
boolean displayID = false; //create boolean variable for displaying imported tweet user IDs
boolean clicked = false; //create a boolean variable to check if the mouse is being pressed
boolean showConnections = false; //a boolean for toggling the connections between particles
int numberGrabbed = 0; //create variable to determine how many tweets are grabbed (ensures only one can be held
int importCounter = 0; //a variable for counting the number of times recent tweets h`` been added
boolean recent = false; //boolean to determine if particle was part of the last set to be imported

ArrayList<tweetParticle> particles;
ArrayList<tweetParticle> recentCache;

// Create sessions using Temboo account to import data sets
TembooSession initialSession = new TembooSession("craigson", "myFirstApp", "2af0bff0408b47198025f032c4eba9d5");
TembooSession additionalSession = new TembooSession("craigson", "additionalTweets", "jwC3QoxjoBoW0lQcpbv7lFuXo4wL1xvD");

DropZone dropZone;

int zoneCounter;

JSONObject initialTwitterData; //new JSON objects
JSONObject recentTwitterData;

boolean reachedLimit = false;
int retrievalCounter = 0;
int recentImportCounter = 0;
int previousRecent =0;

PFont f2;

int infectionCount = 0;
int infectionRatio = 0;

//-----------------------Setup--------------------------
void setup() {
  size(1440, 900, P2D);
  //smooth(4);
  colorMode(HSB, 360, 100, 100);
  leap = new LeapMotion(this);
  handPos = new PVector();

  dropZone = new DropZone(dropZoneRadius);

  shape = loadShape("symbol.svg");
  ebola = loadShape("ebolasmall.svg");
  twitter = loadShape("twittersmall.svg");
  handOpen = loadShape("handOpen.svg");
  handPinched = loadShape("handPinched.svg");
  micro = loadShape("micro.svg");
  shapeMode(CENTER);

  noCursor();
  //initialise font
  f = createFont("Arial", 14);
  f2 = createFont("Avenir-BlackOblique-14", 16);
  textFont(f);

  zoneCounter = 0;

  //thread("retrieveRecentTweets");
  // Run the Tweets Choreo function to retrieve initial batch of tweets
  // thread("retrieveInitialTweets");


  //import JSON file created by retrieveInitialTweets
  initialTwitterData = loadJSONObject("importedData.json");

  //creates an empty array list
  particles = new ArrayList<tweetParticle>();
  recentCache = new ArrayList<tweetParticle>();

  //add first x-number (matches the count of tweets received
  //from runTweetsChoreo() ) of elements to the arrayList (we have to use 
  //Integer.parseInt to convert the String countNo into an integer)

  int countInt = Integer.parseInt(initialCount);
  //add new particles into the ArrayList
  for (int i = 0; i < countInt; i ++) {

    particles.add(new tweetParticle(initialTwitterData, i, new PVector(width/2, height/2), recent));
  } // end of for loop

  for (tweetParticle p : particles) {
    p.spawnTimer.start();
  }
  //start the timer
  timer.start();
  timer2.start();
}

//------------------------draw-----------------------------

void draw() {
  background(360, 0, 20);
  //blendMode(ADD);
  
  infectionCount = 0;

  if (frameCount < 100) {
    shapeMode(CENTER);
    //text("loading", width/2, height/2);
    //shape(shape, width/2, height/2);
    // shape(twitter, 30, 30);
  } else {
    if (timer2.isFinished()) {
      thread("retrieveRecentTweets");
      timer2.start();
      //println("retreving recent!");
    }
    noStroke();
    fill(200,65,95);
    textSize(16);
    stroke(255);
    text("#ebola", 70, 50);
    shape(ebola, 40, 30);

    //code for leap motion
    int fps = leap.getFrameRate();

    for (Hand hand : leap.getHands ()) {
      handPos = hand.getPosition();
      float pinchValue = hand.getPinchStrength();
      if (pinchValue == 1) {
        pinched = true;
      } else {
        pinched = false;
      }
      handY = map(handPos.z, 25, 60, height, 0);
      handX = map(handPos.x, 400, 1200, 0, width);
      handX = constrain(handX, 0, width);
      handY = constrain(handY, 0, height);
    }
    //end of code for leap motion

    /* uncomment out this code to use the leap motion, need to
     changed all mouseX,mouseY variable to handX,handY
     */
     if (pinched == true) {
     clicked = true;
     for (int i = 0; i < particles.size (); i++) {
     tweetParticle particle = particles.get(i);
     //if there are no tweets being held, and a tweet is in range, grab it
     if (numberGrabbed < 1) {
     if (particle.isWithinReach(handX, handY, selectionRange) == true) {
     particle.beingHeld = true; //set the variable inside the particle object to indicate that it has been grabbed
     numberGrabbed = 1; //increase the int numberGrabbed to prevent other tweets from being held
     particle.previousVelocity = particle.velocity;
     particle.previousAcceleration = particle.acceleration;
     } else {
     particle.beingHeld = false;
     numberGrabbed = 0;
     }
     }
     }//end of for loop
     } else {
     clicked = false;
     numberGrabbed = 0; //when the mouse is released, reset the number of tweets being held to 0
     for (int i = 0; i < particles.size (); i++) {
     tweetParticle particle = particles.get(i);
     if (particle.beingHeld == true) {
     float d = dist(dropZone.x, dropZone.y, particle.location.x, particle.location.y);
     if (d < dropZoneRadius && zoneCounter < 1) {
     particle.inTheZone = true;
     zoneIsOccupied = true;
     zoneCounter++;
     } else if (d > dropZoneRadius) {
     particle.inTheZone = false;
     zoneIsOccupied = false;
     zoneCounter = 0;
     }
     }
     particle.beingHeld = false;
     //particle.location = new PVector(handX,handY);
     //particle.velocity = new PVector(handX - phandX, handY - phandY);
     }
     }//end of mouse released
     
     
     

    dropZone.display();

    //we loop backwards through the arrayList because we will eventually be killing off 
    //tweets
    for (int i = 0; i < particles.size (); i++) {
      tweetParticle particle = particles.get(i);
      particle.update();
      particle.display();
      particle.boundaryDetection(30, 30, width-30, height-30);
      particle.checkSpawnTimer();
      particle.displayFullTweet(f);
      particle.avoidTheZone();
      
      if (particle.infected == true){
        infectionCount++;
      }

      //checks if tweets share a hashtag and, if so, draws a connection 
      //using the drawConnections() function
      // if (frameCount % 500 == 0) {
      for (int j = 0; j < particles.size (); j++) {
        tweetParticle tempParticle = particles.get(j);
        // float d = dist(particle.location.x, particle.location.y, tempParticle.location.x, tempParticle.location.y);

        if (i != j) {

          particle.checkForInfection(tempParticle);
          boolean cookies = particle.checkForConnection(tempParticle);

          float d = dist(particle.location.x, particle.location.y, tempParticle.location.x, tempParticle.location.y);
          if ( d < width/4 && cookies==true && showConnections == true) {
            particle.drawConnection(tempParticle);
            PVector force = particle.attract(tempParticle);
            particle.applyForce(force);
          } else {
            PVector force = particle.repel(tempParticle);
            particle.applyForce(force);
          }
        }
      }
      //when new recentTweets are imported, the colour of all existing tweets is returned to normal
      // >>>>>>>>  THIS MUST BE EQUAL TO THE SIZE OF THE NUMBER OF RECENT IMPORTS
      if (i < particles.size() - recentImportCounter) {
        particle.isRecent = false;
      }


      //create strings to store the User's ID and Tweet
      String stringID = particle.userID;
      String stringTweet = particle.tweet;


      //if the mouse pointer is within close proximity of a particle, draw the
      //particle's userID to the screen, if the mouse is pressed while it is within
      //proximity, display the tweet
      if (particle.checkProximity(handX, handY) == true && particle.isRecent == false) {
        textSize(14);
        text(stringID, particle.location.x + selectionRange, particle.location.y, 300, 100);
        if (clicked == true) {
          //  rect(particle.location.x+5 + selectionRange, particle.location.y+20, 300, 100);
          // text(stringTweet, particle.location.x+5 + selectionRange, particle.location.y+20, 300, 100);
          numberGrabbed = 1;
        }
      }

      if (particle.beingHeld == true) {
        // println(particle.inTheZone);
      }
    } //end of for loop

    //when the timer finishes, the importRecent() function imports the 10 most recent tweets
    //the timer is then reset (inside the function) and the timer is restarted, the textTimer
    //is also started to determine how long the new tweet user IDs are displayed for
    if (timer.isFinished()) {
      if (particles.size() < 500) {
        importRecent();
        timer.start();
        textTimer.start();
        displayID = true; //boolean determining whether or not new tweet user IDs are shown
      }
    }

    if (textTimer.isFinished()) {
      displayID = false;
    }

    drawCircle();
    // println(recentImportCounter);

    // text("number of tweets: " + particles.size(), 50, height - 30);
    // text(frameRate, width - 200, height - 30);
    noStroke();


    // println(recentCache.size());

    //this conditional statement adds a recent tweet from the 
    //recentCache array list (every 200 frames), then removes it from recentCache
    if (frameCount % 200 == 0) {
      if (recentCache.size() > 0) {
        tweetParticle temp = recentCache.get(0);
        temp.tempTimer.start();
        temp.spawnTimer.start();
        particles.add(temp);
        recentCache.remove(0);
        if (recentCache.size() > 10) {
          for (int j = 1; j < recentCache.size (); j++) {
            tweetParticle temp2 = recentCache.get(j);
            particles.add(temp2);
            recentCache.remove(j);
          }
        }
      }
    }
    // println(frameCount);
    println(pinched);
    textAlign(LEFT);
    //draw a list of upcoming recent tweets to the display
    if (recentCache.size() > 0) {
      textSize(14);
      // stroke(360, 0, 100);
      fill(200,65,95);
      text("LIVE TWEETS:", 20, 90);
      for (int i = 0; i < recentCache.size (); i++) {
        tweetParticle temp = recentCache.get(i);
        text(temp.userID, 20, 110 + i*18);
      }
      noStroke();
      noFill();
    }
    
    textAlign(LEFT);
  }//end of else statement for loading
} //end of draw


//------------------------keyPressed----------------------

void importRecent() {

  //reset the recentImportCounter to 0
  recentImportCounter = 0;

  //thread() runs simultaneously with draw and only imports the tweets when all of the data
  //is loaded, it prevents the application from stalling / hanging
  //retrieveRecentTweets();
  recent = true;
  recentTwitterData = loadJSONObject("recentTwitterData.json");

  int JSONsize = recentTwitterData.getJSONArray("statuses").size();
  //when the key is pressed, import the ten most recent tweets, extracted from the JSON file that
  //was create by executing the retrieveRecentTweets() using thread()
  for (int i = 0; i < JSONsize; i ++) {
    boolean shouldAdd = true;
    String checkAgainst = recentTwitterData.getJSONArray("statuses").getJSONObject(i).getString("id_str");
    for (tweetParticle p : particles) {
      String check = p.tweetID;

      if (check.equals(checkAgainst)) {
        shouldAdd = false;
      }
      // println(p.tweetID +" " + checkAgainst);
    }
    if (shouldAdd) {
      recentCache.add(new tweetParticle(recentTwitterData, i, new PVector(width/2, height/2), recent));
      recentImportCounter++;
    }
  }
  previousRecent = recentImportCounter;

  /* ---> this prints each tweet to the console
   for (int i = particles.size ()-10; i < particles.size(); i++) {
   tweetParticle particle = particles.get(i);
   println(i + ": " + particle.userID + " - " + particle.tweet);
   }
   */
  importCounter++;
}

//-----------------------mousePressed()-------------------
void mousePressed() {
  clicked = true;
  for (int i = 0; i < particles.size (); i++) {
    tweetParticle particle = particles.get(i);
    //if there are no tweets being held, and a tweet is in range, grab it
    if (numberGrabbed < 1) {
      if (particle.isWithinReach(handX, handY, selectionRange) == true) {
        particle.beingHeld = true; //set the variable inside the particle object to indicate that it has been grabbed
        numberGrabbed++; //increase the int numberGrabbed to prevent other tweets from being held
        particle.previousVelocity = particle.velocity;
        particle.previousAcceleration = particle.acceleration;
      } else {
        particle.beingHeld = false;
      }
    }
  }//end of for loop
}//end of mousePressed

//-------------------------mouserReleased-------------------

void mouseReleased() {
  clicked = false;
  numberGrabbed = 0; //when the mouse is released, reset the number of tweets being held to 0
  for (int i = 0; i < particles.size (); i++) {
    tweetParticle particle = particles.get(i);
    if (particle.beingHeld == true) {
      float d = dist(dropZone.x, dropZone.y, particle.location.x, particle.location.y);
      if (d < dropZoneRadius && zoneCounter < 1) {
        particle.inTheZone = true;
        zoneCounter++;
      } else if (d > dropZoneRadius) {
        particle.inTheZone = false;
        zoneCounter = 0;
      }
    }
    particle.beingHeld = false;
    //particle.location = new PVector(handX,handY);
    //particle.velocity = new PVector(handX - phandX, handY - phandY);
  }
}//end of mouse released

//--------------------------drawCircle()-------------------

void drawCircle() {
  noStroke();
  fill(255, 50);
  ellipse(handX, handY, selectionRange*2, selectionRange*2);

  if (mousePressed == true || pinched == true){
shape(handPinched, handX + selectionRange, handY+selectionRange);
  } else {
      shape(handOpen, handX + selectionRange + 10, handY+selectionRange + 10);
  }
}


//-----------------------------keyPressed()-----------------------------

void keyPressed() {
  showConnections = !showConnections;
}
