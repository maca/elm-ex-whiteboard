module Whiteboard.Serialization exposing (..)

import Mouse exposing (Position)
import Json.Encode as Encode
import Json.Decode as Decode exposing
  (field, at, maybe, decodeString, decodeValue)

import Whiteboard.Types exposing (..)


-- ENCODING
pointEncoder : Client -> Point -> Encode.Value
pointEncoder client point =
  Encode.object
    [ ( "x",         Encode.int point.x )
    , ( "y",         Encode.int point.y )
    , ( "id",        Encode.int point.id )
    , ( "line_id",   Encode.int point.lineId )
    , ( "color",     Encode.string client.color )
    , ( "width",     Encode.string client.width )
    , ( "client_id", Encode.string client.id )
    ]


-- DECODING
clientDecoder : Decode.Decoder Client
clientDecoder =
  Decode.map4 Client
    (Decode.succeed [])
    (field "color"     Decode.string)
    (field "width"     Decode.string)
    (field "client_id" Decode.string)


pointDecoder : Decode.Decoder Point
pointDecoder =
  Decode.map4 Point
    (field "x"       Decode.int)
    (field "y"       Decode.int)
    (field "id"      Decode.int)
    (field "line_id" Decode.int)


pointDataDecoder : Decode.Decoder ( Client, Point )
pointDataDecoder =
  Decode.map2 (,) clientDecoder pointDecoder


pointsDataDecoder : Decode.Decoder (List ( Client, Point ))
pointsDataDecoder  =
  Decode.at ["points"] (Decode.list pointDataDecoder)


offsetDecoder : Decode.Decoder Position
offsetDecoder =
  let
      xOffset =
        Decode.map2 (-)
          (field "pageX" Decode.int)
          (field "offsetX" Decode.int)

      yOffset =
        Decode.map2 (-)
          (field "pageY" Decode.int)
          (field "offsetY" Decode.int)

  in
      Decode.map2 Position xOffset yOffset


mouseDownDecoder : Decode.Decoder Msg
mouseDownDecoder =
  offsetDecoder |>
    Decode.andThen (\pos -> Decode.succeed (AddLine pos))


