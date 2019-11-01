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
    console.log("Successfully copied")
  }
  catch(err){
    console.log(`Failed: ${err.message}`)
  }
}

function copyToS3(url, key) {
  return new Promise(function (resolve, reject) {
    https.get(url, function onResponse(res) {
      if (res.statusCode >= 300) {
        reject(new Error('error ' + res.statusCode + ' retrieving ' + url));
      }
      s3.upload({Bucket: targetBucket, Key: key, Body: res}, function (err, data) {
        if (err) {
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

exports.handler = async function(event, context) {
  event.Records.forEach(record => {
    const { body } = record;
    const params = JSON.parse(body);
    processCsv(params['downloadUrl'], params['table'], params['kind']);
  });
  return {};
};
