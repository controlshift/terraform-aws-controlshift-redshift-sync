'use strict';

const aws = require('aws-sdk');
const lambda = new aws.Lambda({
  // region: 'us-west-2'
});

function sendResponse(body) {
    let response =  {
        isBase64Encoded: false,
        statusCode: 200,
        headers: {'Content-Type': 'application/json', 'x-controlshift-processed': '1'},
        body: JSON.stringify(body)
    };
    console.log("response: " + JSON.stringify(response));
    return response;
}

function invokeLambda(payload) {
  const params = {
    FunctionName: 'controlshift-webhook-handler',
    Payload: JSON.stringify(payload),
    InvocationType: 'Event'
  };

  return new Promise((resolve, reject) => {
    lambda.invoke(params, (err, data) => {
      if (err) {
        console.log('Error invoking receiver lambda:', err);
        reject(err);
      }
      else {
        console.log('Successfully invoked receiver with data:', data);
        resolve(data);
      }
    });
  });
}

// Lambda event Handler
exports.handler = async (event) => {
    let receivedJSON = JSON.parse(event.body);
    console.log('Received event:', receivedJSON);

    await invokeLambda({ body: receivedJSON });

    return Promise.resolve(sendResponse({"status": "processed", "payload": receivedJSON}));
};
