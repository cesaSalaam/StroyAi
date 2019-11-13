
var express = require('express');
var app = express();

app.set('port', (process.env.PORT || 5000));

var bodyParser = require('body-parser')      // to support JSON-encoded bodies

app.use(bodyParser.urlencoded({ extended: true }));
app.use( bodyParser.json() );
app.use(express.json());       // to support JSON-encoded bodies
app.use(express.urlencoded()); // to support URL-encoded bodies


const NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
const naturalLanguageUnderstanding = new NaturalLanguageUnderstandingV1({
  version: '2018-11-16',
  iam_apikey: 'iTxVCHk6iO8Y0mnF-BzWraBDcJXb86OaApnajVdEHIbq',
  url: 'https://gateway-wdc.watsonplatform.net/natural-language-understanding/api'
});

app.post('/analysis', function(req, res) {
  console.log(req.body.text);

  const analyzeParams = {
    'text': req.body.text,
    'features': {
      'emotion': {}
    }
  };
  naturalLanguageUnderstanding.analyze(analyzeParams)
    .then(analysisResults => {
      //console.log(analysisResults);
      //console.log(JSON.stringify(analysisResults, null, 2));
      var temp = JSON.stringify(analysisResults, null, 2);
      console.log(temp);
      res.json({
        status: "SUCCESS",
        analysis: analysisResults
      })
    })
    .catch(err => {
      console.log('error:', err);
      res.send(err);
    });
});



  app.get('/*', function(req, res) { //route all other  requests here
            res.status(200);
            res.send("<b>THE SERVER IS RUNNING</b>");
  }).listen(app.get('port'), function() {
      console.log('App is running, server is listening on port ', app.get('port'));
  });
  module.exports = app;
