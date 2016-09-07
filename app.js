'use strict';

var awsIot = require('aws-iot-device-sdk');
var Chance = require('chance'); // used to randomize bool values
var chance = new Chance();

// used to add linebreaks to cert strings
var pattern = /#####/g;

var device = awsIot.device({
  privateKey: new Buffer(process.env.AWS_PRIVATE_KEY.replace(pattern, '\n')),
  clientCert: new Buffer(process.env.AWS_CERT.replace(pattern, '\n')),
      caCert: new Buffer(process.env.AWS_ROOT_CA.replace(pattern, '\r\n')),
    clientId: process.env.RESIN_DEVICE_UUID,
      region: process.env.AWS_REGION
});

var path = 'rotated/images/'
var spawn = require('child_process').spawn;

device.on('connect', function() {
  console.log('connect');
  device.subscribe('sensor');
  // publish data
  // setInterval(function () {
    // var reading = chance.floating({min: 0, max: 200});
    // device.publish('sensor', JSON.stringify({ reading: reading }));
  // }, process.env.INTERVAL || 3000);
});

device.on('message', function(topic, payload) {
  console.log('message', topic, payload.toString());

  var ls = spawn('fbi', ['-d', '/dev/fb1', '-T', '1', '-noverbose', '-a', path + payload.toString() + '.png']);

  ls.stdout.on('data', (data) => {
      console.log(`stdout: ${data}`);
  });

  ls.stderr.on('data', (data) => {
      console.log(`stderr: ${data}`);
  });

  ls.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
  });
});

