module Whiteboard exposing
  (Model, Msg, initModel, update, view, subscriptions)

import Html exposing (Html)

import Whiteboard.Types exposing (..)
import Whiteboard.State exposing (..)
import Whiteboard.View


type alias Model  = Whiteboard.Types.Model
type alias Msg    = Whiteboard.Types.Msg


initModel : Flags -> Model
initModel = Whiteboard.State.initModel


update : Msg -> Model -> ( Model, Cmd Msg )
update = Whiteboard.State.update


subscriptions : Model -> Sub Msg
subscriptions = Whiteboard.State.subscriptions


view : Model -> Html Msg
view = Whiteboard.View.view


main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

