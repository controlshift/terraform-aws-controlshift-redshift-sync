'use strict';

const request = require('request');
const stream = require('stream');
const AWS = require('aws-sdk');

const targetBucket = process.env.S3_BUCKET; // receiver bucket name
const s3 = new AWS.S3();

function processCsv(downloadUrl, table, kind) {
  console.log("Processing: " + downloadUrl);

  try {
    const today = new Date();
    const keyParts =  [kind, table, today.getFullYear(), today.getMonth(), today.getDate(),
      `${today.getHours()}-${today.getMinutes()}-${today.getSeconds()}`, 'table.csv'];
    const key = keyParts.join('/');
    copyToS3(downloadUrl, key);
    console.log("Successfully copied")
  }
  catch(err){
    console.log(`Failed: ${err.message}`)
  }
}

const uploadStream = ({ key }) => {
  const s3 = new AWS.S3();
  const pass = new stream.PassThrough();
  return {
    writeStream: pass,
    promise: s3.upload({ Bucket: targetBucket, Key: key, Body: pass }).promise(),
  };
};

function copyToS3(url, key) {
  const { writeStream, promise } = uploadStream({key: key});
  request({method: 'GET', uri: url, timeout: 5000, gzip: true})
    .on('error', function(err) {
      console.error(err)
    })
    .pipe(writeStream);
  promise.then(console.log);
}

exports.handler =  function(event, context) {
  event.Records.forEach(record => {
    const { body } = record;
    const params = JSON.parse(body);
    console.log('Processing record in SQS: ' + body);
    processCsv(params['downloadUrl'], params['table'], params['kind']);
  });
  return {};
};
