void retrieveInitialTweets() {

  //create a new json object
  JSONObject json;



  // Create the Choreo object using your Temboo session
  Tweets tweetsChoreo = new Tweets(initialSession);
  
  tweetsChoreo.setCredential("maxImports");

  // Set inputs
  tweetsChoreo.setCount(initialCount);
 // tweetsChoreo.setAccessToken("2891711796-PlDTEVANONl3gWTcUOPXQyEXfszF0lG9LHkMWbx");
  tweetsChoreo.setQuery("#ebola");
 // tweetsChoreo.setAccessTokenSecret("RQEizZxTQgtqkrcMYr6nCFiUsAr6bxbG4zMorOmMqTOfa");
 // tweetsChoreo.setConsumerSecret("zqXKdn6xRsXc3WQPsMo9cXn2tZvxswdB4V0llLu3tvGvqtyMlJ");
  tweetsChoreo.setLanguage("en");
 // tweetsChoreo.setConsumerKey("LSbb1STZ6ERxZOWIjv2C7CBRW");
  tweetsChoreo.setResultType("mixed");

  // Run the Choreo and store the results
  TweetsResultSet tweetsResults = tweetsChoreo.run();

  //create a string from choreo results
  String importedData = tweetsResults.getResponse();

  //initialise json object with json data from string
  json = new JSONObject().parse(importedData);

  //save json file to external .json doc
  saveJSONObject(json, "data/importedData.json");

  //println(tweetsResults.getResponse());
  //println(tweetsResults.getLimit());
  //println(tweetsResults.getRemaining());
  // rintln(tweetsResults.getReset());
} //end of runTweetsChoreo
