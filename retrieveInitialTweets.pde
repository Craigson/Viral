void retrieveInitialTweets() {

  //create a new json object
  JSONObject json;



  // Create the Choreo object using your Temboo session
  Tweets tweetsChoreo = new Tweets(initialSession);
  
  tweetsChoreo.setCredential("maxImports");

  // Set inputs
  tweetsChoreo.setCount(initialCount);
  tweetsChoreo.setQuery("#ebola");
  tweetsChoreo.setLanguage("en");
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
