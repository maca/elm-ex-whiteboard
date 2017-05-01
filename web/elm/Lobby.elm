module Lobby exposing (..)

import Html exposing (Html, div, form, input, h1, p, a, span, button, text)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value, disabled, id, attribute, style, href)
import Regex exposing (regex, contains)


type alias Model =
  { origin: String
  , name: String
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
    Input name ->
      ( { model | name = name }, Cmd.none )


view : Model -> Html Msg
view { origin, name } =
  let
      url = origin ++ name
      nameBlank = not <| contains (regex "\\w") name

      formAttrs =
        if nameBlank then
          [ ]
        else
          [ attribute "onsubmit" <| redirectTo url ]

  in
      form
        formAttrs
        [ greetingsText name url nameBlank
        , div
          []
          [ input
              [ onInput Input, value name ]
              [ ]
          , button
              [ disabled nameBlank ]
              [ text "Go!" ]
          ]
        ]


greetingsText : String -> String -> Bool -> Html Msg
greetingsText name url nameBlank =
  p
    [ ]
    [ text "Just choose any name you want for your whiteboard and then share "
    , if nameBlank then (text "the url") else (whiteboardUrl url)
    , text " with your friends."
    ]


whiteboardUrl : String -> Html Msg
whiteboardUrl url =
  span [ ] [ text "this url ", a [ href url ] [ text url ] ]


redirectTo : String -> String
redirectTo destination =
  "window.location.href = '" ++ destination ++ "'; return false;"

