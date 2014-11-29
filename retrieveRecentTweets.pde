void retrieveRecentTweets() {

  JSONObject recentJson;

  // Create the Choreo object using your Temboo session
  Tweets tweetsChoreo = new Tweets(additionalSession);

  // Set inputs
  tweetsChoreo.setCount("10");
  tweetsChoreo.setAccessToken("2891711796-hiNMzesi9XkVztVPNy6wlCa3gaatPELwgZZAAye");
  tweetsChoreo.setQuery("#ebola");
  tweetsChoreo.setAccessTokenSecret("wesUm5jOLPLPOg30ExJc3BABHLbCc7MoAFkPCFiVx2AnS");
  tweetsChoreo.setConsumerSecret("6loGUsnNSppf1XsNRPfEbHHRqiT1lUtmrUAMguDfCCtPyaFGQX");
  tweetsChoreo.setLanguage("en");
  tweetsChoreo.setConsumerKey("x9PMA2JEKIOLBZxqJRgW9tG0X");
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
