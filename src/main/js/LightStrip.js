var motor;
function setMode(mode) {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.open('GET', 'api/system:' + mode, true);
  xmlHttp.send(null);
}

function setColor(color) {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.open('PATCH', 'api/led/1', true);
  xmlHttp.send(JSON.stringify({entity: {color: color}}));
}

function getMotor(index) {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      motor = JSON.parse(xmlHttp.response);
    }
  };
  xmlHttp.open('GET', 'api/motor/' + index, true);
  xmlHttp.send(null);
}

function startMotor() {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.open('GET', 'api/motor:start', true);
  xmlHttp.send(null);
}

function stopMotor() {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.open('GET', 'api/motor:stop', true);
  xmlHttp.send(null);
}

function setMotorSpeed(speed) {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      motor = JSON.parse(xmlHttp.response);
    }
  };
  xmlHttp.open('PATCH', 'api/motor/1', true);
  xmlHttp.send(JSON.stringify({entity: {speed: speed}, updateMask: ['speed']}));
}
