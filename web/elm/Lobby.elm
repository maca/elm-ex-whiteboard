module Lobby exposing (..)

import Html exposing (Html, div, form, input, h1, p, a, span, button, text)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (autofocus, value, disabled, id, attribute, style, href)
import Regex exposing (regex, contains)


type alias Model =
  { origin: String
  , room: String
  }


type alias Flags = {
  origin: String
}


type Msg =
  Input String



init : Flags -> ( Model, Cmd Msg )
init { origin } =
  ( Model (origin ++ "/") "", Cmd.none )


main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Input room ->
      ( { model | room = room }, Cmd.none )


view : Model -> Html Msg
view { origin, room } =
  let
      url = origin ++ room
      roomBlank = not <| contains (regex "\\w") room

      formAttrs =
        if roomBlank then
          [ ]
        else
          [ attribute "onsubmit" <| redirectTo url ]

  in
      form
        formAttrs
        [ greetingsText url roomBlank
        , div
          []
          [ input
              [ onInput Input
              , value room
              , autofocus True
              ]
              [ ]
          , button
              [ disabled roomBlank ]
              [ text "Go!" ]
          ]
        ]


greetingsText : String -> Bool -> Html Msg
greetingsText url roomBlank =
  p
    [ ]
    [ text "Just choose any name you want for your whiteboard and then share "
    , if roomBlank then (text "the url") else (whiteboardUrl url)
    , text " with your friends."
    ]


whiteboardUrl : String -> Html Msg
whiteboardUrl url =
  span [ ] [ text "this url ", a [ href url ] [ text url ] ]


redirectTo : String -> String
redirectTo destination =
  "window.location.href = '" ++ destination ++ "'; return false;"

