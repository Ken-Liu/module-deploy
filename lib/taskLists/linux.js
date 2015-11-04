var nodemiral = require('nodemiral');
var fs = require('fs');
var path = require('path');
var util = require('util');
var _ = require('underscore');

var SCRIPT_DIR = path.resolve(__dirname, '../../scripts/linux');
var TEMPLATES_DIR = path.resolve(__dirname, '../../templates/linux');

exports.setup = function(config) {
  var taskList = nodemiral.taskList('Setup (linux)');

 
  if(config.setupWiki) {
    taskList.copy('Copying wiki configuration', {
      src: path.resolve('./', config.configname),
      dest: '/opt/wiki/config.yaml'
    });

  /*  taskList.executeScript('Installing wiki', {
      script: path.resolve(SCRIPT_DIR, 'start.sh')
    });
  }*/
  return taskList;
};
/*
exports.reconfig = function(env, config) {
  var appName = config.appName;
  var deployCheckWaitTime = config.deployCheckWaitTime;

  var taskList = nodemiral.taskList("Updating configurations (linux)");

  copyEnvVars(taskList, env, appName);
  //startAndVerify(taskList, appName, env.PORT, deployCheckWaitTime, config.meteor_container_port);

  return taskList;
};*/

exports.restart = function(config) {
  var taskList = nodemiral.taskList("Restarting Application (linux)");

  var appName = config.appName;
  var port = config.env.PORT;
  //var virtual_host = env.virtual_host;
  var meteor_container_port = config.meteor_container_port;
  var deployCheckWaitTime = config.deployCheckWaitTime;

  startAndVerify(taskList, appName, port, deployCheckWaitTime, meteor_container_port);

  return taskList;
};

exports.stop = function(config) {
  var taskList = nodemiral.taskList("Stopping Application (linux)");

  //stopping
  taskList.executeScript('Stopping app', {
    script: path.resolve(SCRIPT_DIR, 'stop.sh'),
    vars: {
      appName: config.appName
    }
  });

  return taskList;
};

exports.start = function(config) {
  var taskList = nodemiral.taskList("Starting Application (linux)");

  var appName = config.appName;
  var port = config.env.PORT;
  var deployCheckWaitTime = config.deployCheckWaitTime;

  startAndVerify(taskList, appName, port, deployCheckWaitTimei,config.meteor_container_port);

  return taskList;
};

function installStud(taskList) {
  taskList.executeScript('Installing Stud', {
    script: path.resolve(SCRIPT_DIR, 'install-stud.sh')
  });
}

function copyEnvVars(taskList, env, appName) {
  var env = _.clone(env);
  // sending PORT to the docker container is useless.
  // It'll run on PORT 80 and we can't override it
  // Changing the port is done via the start.sh script
  delete env.PORT;
  taskList.copy('Sending environment variables', {
    src: path.resolve(TEMPLATES_DIR, 'env.list'),
    dest: '/opt/' + appName + 'env.list',
    vars: {
      env: env || {},
      appName: appName
    }
  });
}

function startAndVerify(taskList, appName, port, deployCheckWaitTime , meteor_container_port) {
  taskList.execute('Starting app', {
    command: "bash /opt/" + appName + "/start.sh"
  });

  // verifying deployment
  taskList.executeScript('Verifying deployment', {
    script: path.resolve(SCRIPT_DIR, 'verify-deployment.sh'),
    vars: {
      deployCheckWaitTime: deployCheckWaitTime || 10,
      appName: appName,
      meteor_container_port: meteor_container_port,
      port: port
    }
  });
}

function deployAndVerify(taskList, appName, port, deployCheckWaitTime , meteor_container_port) {
  // deploying
 /* taskList.executeScript('Invoking deployment process', {
    script: path.resolve(SCRIPT_DIR, 'deploy.sh'),
    vars: {
      appName: appName
    }
  });*/

  // verifying deployment
  taskList.executeScript('Verifying deployment', {
    script: path.resolve(SCRIPT_DIR, 'verify-deployment.sh'),
    vars: {
      deployCheckWaitTime: deployCheckWaitTime || 10,
      appName: appName,
      meteor_container_port: meteor_container_port,
      port: port
    }
  });
}
