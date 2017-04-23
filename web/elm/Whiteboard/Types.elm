module Whiteboard.Types exposing (..)

import Json.Encode as Encode
import Mouse exposing (Position)
import Window exposing (Size)


type alias Flags =
  { clientId: String }


type alias Point =
  { x: Int
  , y: Int
  , id: Int
  , lineId: Int
  }


type alias Line =
  { points: List Point
  , color: String
  , width: String
  , id: Int
  }


type alias Client =
  { lines : List Line
  , color : String
  , width : String
  , id : String
  }


type alias Model =
  { clients : List Client
  , windowSize : Size
  , offset : Position
  , clientId: String
  , drawing : Bool
  }


type Msg =
  Draw Position
    | AddLine Position
    | StopDrawing Position
    | Resize Size
    | UpdateColor String
    | UpdateWidth String
    | ReceivePoint Encode.Value
    | ReceivePoints Encode.Value
