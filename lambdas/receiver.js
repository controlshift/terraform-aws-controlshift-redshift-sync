'use strict';

const AWS = require('aws-sdk');

// Set the region
AWS.config.update({region: process.env.AWS_REGION});

// Create an SQS service object
const sqs = new AWS.SQS({apiVersion: '2012-11-05'});

function enqueueTask(downloadUrl, table, kind) {
  console.log("Processing: " + downloadUrl);

  let messageBody = {};
  messageBody['downloadUrl'] = downloadUrl;
  messageBody['table'] = table;
  messageBody['kind'] =  kind;

  const params = {
    MessageBody: JSON.stringify(messageBody),
    QueueUrl: process.env.SQS_QUEUE_URL
  };

  sqs.sendMessage(params, function (err, data) {
    if (err) {
      console.log("Error", err);
    } else {
      console.log("Success", data.MessageId);
    }
  });
  return sendResponse({"status": "processed"})
}

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

// Lambda event Handler
exports.handler = async (event) => {
    let receivedJSON = JSON.parse(event.body);
    console.log('Received event:', receivedJSON);
    if(receivedJSON.type === 'data.full_table_exported'){
        return enqueueTask(receivedJSON.data.url, receivedJSON.data.table, 'full');
    } else if(receivedJSON.type === 'data.incremental_table_exported'){
        return enqueueTask(receivedJSON.data.url, receivedJSON.data.table, 'incremental');
    } else {
        return Promise.resolve(sendResponse({"status": "skipped", "payload": receivedJSON}));
    }
};
