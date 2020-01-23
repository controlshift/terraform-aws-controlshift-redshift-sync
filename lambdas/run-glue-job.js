'use strict';

const AWS = require('aws-sdk');
// Set the region
AWS.config.update({region: process.env.AWS_REGION});

// Create an SQS service object
const sqs = new AWS.SQS();
const glue = new AWS.Glue();
const jobName = 'glue-job-name';

exports.handler = async function(event, context) {
  glue.startJobRun({JobName: jobName}, function(error, data) {
    if(error) {
      console.log(error, error.stack);
    } else {
      console.log(data);
    }
  });

  return {};
};
