var modes = [];
var selectedMode;

function redraw() {
  var innerHTML = '';
  for (var i = 0; i < modes.length; i++) {
    var mode = modes[i];
    innerHTML += '<option value="' + mode.id + '">' + mode.name + '</option>';
  }
  document.getElementById('modes').innerHTML = innerHTML;
}

function setSelected() {
  var id = document.getElementById('modes').value;
  console.log('Selected mode id: ' + id);
  for (var i = 0; i < modes.length; i++) {
    if (modes[i].id == id) {
      selectedMode = modes[i];
    }
  }
  document.getElementById("name").value = selectedMode.name;
  document.getElementById("code").value = selectedMode.code;
}

function createMode() {
  var newMode = {
    name: document.getElementById("name").value,
    code: document.getElementById("code").value
  };
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      newMode = JSON.parse(xmlHttp.response);
      modes.push(newMode);
      redraw();
    }
  };
  xmlHttp.open('POST', '/api/modes/', true);
  xmlHttp.send(JSON.stringify({entity: newMode}));
}

function getMode(id) {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      selectedMode = JSON.parse(xmlHttp.response);
    }
  };
  xmlHttp.open('GET', '/api/modes/' + id, true);
  xmlHttp.send(null);
}

function refreshModes() {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      var response = JSON.parse(xmlHttp.response);
      modes = [];
      for (var i = 0; i < response.result.length; i++) {
        modes.push(response.result[i]);
      }
      redraw();
    }
  };
  xmlHttp.open('GET', '/api/modes', true);
  xmlHttp.send(null);
}

function updateMode() {
  var updateRequest = {
    entity: {
      name: document.getElementById("name").value,
      code: document.getElementById("code").value
    },
    updateMask: ['name', 'code']
  };
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      var updated = JSON.parse(xmlHttp.response);
      modes.splice(modes.indexOf(selectedMode), 1, updated);
      selectedMode = updated;
      redraw();
    }
  };
  xmlHttp.open('PATCH', '/api/modes/' + selectedMode.id, true);
  xmlHttp.send(JSON.stringify(updateRequest));
}

function deleteMode() {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      splice(modes.indexOf(selectedMode), 1);
      redraw();
    }
  };
  xmlHttp.open('DELETE', '/api/modes/' + selectedMode.id, true);
  xmlHttp.send(null);
}

function setActiveMode() {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.open('GET', 'api/modes/' + selectedMode.id + ':setActive', true);
  xmlHttp.send(null);
}

function reset() {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.open('GET', 'api/modes:reset', true);
  xmlHttp.send(null);
}

refreshModes();

function setColor() {
  var xmlHttp = new XMLHttpRequest();
  var color = document.getElementById("html5colorpicker").value;
  console.log('Color: ' + color);
  var url = 'api/colors:setActive?color=c' + color.substring(1);
  console.log('url: ' + url);
  xmlHttp.open('GET', url, true);
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
