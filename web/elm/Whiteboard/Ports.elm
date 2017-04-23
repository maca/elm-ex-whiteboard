port module Whiteboard.Ports exposing (..)

import Json.Decode
import Json.Encode as Encode


port sendPoint     : Encode.Value -> Cmd msg
port receivePoint  : (Encode.Value -> msg) -> Sub msg
port receivePoints : (Encode.Value -> msg) -> Sub msg
