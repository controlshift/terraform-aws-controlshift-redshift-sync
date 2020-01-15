'use strict';

const https = require('https');
const AWS = require('aws-sdk');

const targetBucket = process.env.S3_BUCKET; // receiver bucket name
const s3 = new AWS.S3();

async function processCsv(downloadUrl, table, kind) {
    console.log("Processing: " + downloadUrl);

    try {
      const today = new Date();
      const key = `${kind}/${table}/${today.getFullYear()}/${today.getMonth()}/${today.getDate()}/${today.getHours()}-${today.getMinutes()}-${today.getSeconds()}/table.csv`;
      await copyToS3(downloadUrl, key);
      console.log(`Successfully copied ${downloadUrl} to ${key}`)
    }
    catch(err){
      console.log(`Failed: ${err.message} (${downloadUrl})`)
    }
    finally{
      return sendResponse({"status": "processed"})
    }
}

function copyToS3(url, key) {
  return new Promise(function(resolve, reject){
    https.get(url, function onResponse(res) {
      if (res.statusCode >= 300) {
        reject(new Error('error ' + res.statusCode + ' retrieving ' + url));
      }
      s3.upload({Bucket: targetBucket, Key: key, Body: res}, function(err, data){
        if(err){
          reject(err)
        }
        resolve(data)
      });
    })
      .on('error', function onError(err) {
        reject(err);
      });
  })
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
    // let receivedJSON = JSON.parse(event.body);
    let receivedJSON = event.body;
    console.log('Received event:', receivedJSON);
    if(receivedJSON.type === 'data.full_table_exported'){
        return processCsv(receivedJSON.data.url, receivedJSON.data.table, 'full');
    } else if(receivedJSON.type === 'data.incremental_table_exported'){
        return processCsv(receivedJSON.data.url, receivedJSON.data.table, 'incremental');
    } else {
        return Promise.resolve(sendResponse({"status": "skipped", "payload": receivedJSON}));
    }
};
