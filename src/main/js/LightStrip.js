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
