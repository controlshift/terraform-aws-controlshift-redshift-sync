'use strict';

const request = require('request');
const stream = require('stream');
const AWS = require('aws-sdk');

const targetBucket = process.env.S3_BUCKET; // receiver bucket name
const s3 = new AWS.S3();

function processCsv(params) {
  console.log("Processing: " + params.downloadUrl);

  try {
    const today = new Date();
    const keyParts =  [params.kind, params.table, today.getFullYear(), today.getMonth(), today.getDate(),
      `${today.getHours()}-${today.getMinutes()}-${today.getSeconds()}`, 'table.csv'];
    const key = keyParts.join('/');
    if (params['s3'] === undefined) {
      downloadAndStreamToS3(params.downloadUrl, key);
    } else {
      nativeS3Copy(params.s3, key)
    }
  }
  catch(err){
    console.log(`Failed: ${err.message}`)
  }
}

function nativeS3Copy(cslS3Obj, key) {
  if (process.env.CSL_ROLE_ARN === undefined) {
    throw("must provide a CSL_ROLE_ARN to use nativeS3Copy");
  }

  const copyParams = {
    Bucket: process.env.S3_BUCKET,
    Key: key,
    CopySource: `/${cslS3Obj.bucket}/${cslS3Obj.key}`
  };

  s3.copyObject(copyParams, function (err, data) {
    if (err) { // an error occurred
      console.log(err, err.stack);
    } else {  // successful response
      console.log(data);
      console.log('Successfully Copied');
    }
  });
}

const uploadStream = ({ key }) => {
  const pass = new stream.PassThrough();
  return {
    writeStream: pass,
    promise: s3.upload({ Bucket: targetBucket, Key: key, Body: pass }).promise(),
  };
};

function downloadAndStreamToS3(url, key) {
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
    processCsv(params);
  });
  return {};
};
