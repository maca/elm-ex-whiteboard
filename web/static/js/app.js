import "phoenix_html"
import socket from "./socket"


var elmDiv = document.getElementById('whiteboard-app')
  , flags = { clientId: elmDiv.dataset.clientId }
  , elmWhiteboard = Elm.Whiteboard.embed(elmDiv, flags);


let channel = socket.channel(elmDiv.dataset.channel, {});


channel.join()
  .receive("error",
    resp => { console.log("Unable to join", resp) }
  );


elmWhiteboard.ports.sendPoint.subscribe(
  point => { channel.push("new-point", point) }
);


channel.on('new-point', data => {
  elmWhiteboard.ports.receivePoint.send(data)
});


channel.on('set-state', data => {
  elmWhiteboard.ports.receivePoints.send(data)
});

