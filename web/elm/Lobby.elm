module Lobby exposing (..)

import Html exposing (Html, div, form, h1, p, a, span, button, text)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value, id, attribute, style, href)


type alias Model =
  { origin: String
  , input: String
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
    Input input ->
      ( { model | input = input }, Cmd.none )


view : Model -> Html Msg
view { origin, input } =
  let
      url = origin ++ input
      redirect = redirectTo url

  in
      form
        [ attribute "onsubmit" redirect ]
        [ greetingsText input url
        , div
          []
          [ Html.input
              [ onInput Input, value input ]
              [ ]
          , button
              [ ]
              [ text "Go!" ]
          ]
        ]


greetingsText : String -> String -> Html Msg
greetingsText input url =
  p
    [ ]
    [ text "Just choose any name you want for your whiteboard and then share "
    , if input == "" then (text "the url") else (whiteboardUrl url)
    , text " with your friends."
    ]


whiteboardUrl : String -> Html Msg
whiteboardUrl url =
  span [ ] [ text "this url ", a [ href url ] [ text url ]]


redirectTo : String -> String
redirectTo destination =
  "window.location.href = '" ++ destination ++ "'; return false;"
