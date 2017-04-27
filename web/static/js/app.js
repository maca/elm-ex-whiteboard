import "phoenix_html"
import socket from "./socket"

const whiteboardElem = document.getElementById('whiteboard-app')
  , lobbyElem = document.getElementById('lobby-app')

if (whiteboardElem) { initWhiteboard(whiteboardElem) }

if (lobbyElem) {
  Elm.Lobby.embed(lobbyElem, { origin: window.location.origin })
}

function initWhiteboard(elmElem) {
  const channel = socket.channel(elmElem.dataset.channel, {})
    , flags = { clientId: elmElem.dataset.clientId }
    , elmWhiteboard = Elm.Whiteboard.embed(elmElem, flags)

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
}
