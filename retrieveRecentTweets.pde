void retrieveRecentTweets() {

  JSONObject recentJson;

  // Create the Choreo object using your Temboo session
  Tweets tweetsChoreo = new Tweets(additionalSession);

  // Set inputs
  tweetsChoreo.setCount("10");
  tweetsChoreo.setAccessToken("YOUR_TOKEN_HERE");
  tweetsChoreo.setQuery("#ebola");
  tweetsChoreo.setAccessTokenSecret("YOUR_TOKEN_SECRET_HERE");
  tweetsChoreo.setConsumerSecret("YOUR_CONSUMER_SECRET");
  tweetsChoreo.setLanguage("en");
  tweetsChoreo.setConsumerKey("YOUR_CONSUMER_KEY");
  tweetsChoreo.setResultType("recent");

  // Run the Choreo and store the results
  TweetsResultSet recentTweetsResults = tweetsChoreo.run();

  //create a string from choreo results
  String recentTwitterData = recentTweetsResults.getResponse();

  //initialise json object with json data from string
  recentJson = new JSONObject().parse(recentTwitterData);

  //save json file to external .json doc
  saveJSONObject(recentJson, "data/recentTwitterData.json");

  // Print results
  // println(recentTweetsResults.getResponse());
  //  println(recentTweetsResults.getLimit());
  //  println(recentTweetsResults.getRemaining());
  // println(recentTweetsResults.getReset());
}
