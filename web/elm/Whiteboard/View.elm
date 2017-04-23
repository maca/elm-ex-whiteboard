module Whiteboard.View exposing (view)


import Html exposing (..)
import Html.Events exposing (on, onClick, onMouseDown)
import Html.Attributes exposing
  (class, id, attribute, style)
import List exposing (sortBy, foldl, foldr)
import Svg exposing (Svg, svg, polyline)
import Svg.Attributes exposing (viewBox, fill, stroke
  , strokeWidth, width, height, points)
import String exposing (join)


import Whiteboard.Types exposing (..)
import Whiteboard.Serialization exposing (..)


-- VIEW
view : Model -> Html Msg
view model =
  let
      { width, height } = model.windowSize

  in
      div
        [ class "whiteboard"
        , style [ ("height", "100%") ]
        ]
        [ renderToolBox
        , renderWhiteboard model
            (toString width)
            (toString height)
        ]


renderButton : Msg -> Html Msg
renderButton msg =
  let
      render btnClass btnText =
        button
          [ onClick msg
          , class btnClass
          , class <| btnClass ++ "-" ++ btnText
          ]
          [ text btnText ]

  in
      case msg of
        UpdateColor btnText ->
          render "update-color" btnText

        UpdateWidth btnText ->
          render "update-width" btnText

        _ -> text ""


renderToolBox : Html Msg
renderToolBox =
  div
    [ class "whiteboard-toolbox" ]
    [ renderButton (UpdateColor "red")
    , renderButton (UpdateColor "green")
    , renderButton (UpdateColor "blue")
    , renderButton (UpdateColor "black")
    , renderButton (UpdateWidth "2px")
    , renderButton (UpdateWidth "3px")
    , renderButton (UpdateWidth "6px")
    , renderButton (UpdateColor "white")
    ]


renderWhiteboard : Model -> String -> String -> Html Msg
renderWhiteboard model widthString heightString =
  svg [ width widthString
    , height heightString
    , viewBox ("0 0 " ++ widthString  ++ " " ++ heightString)
    , on "mousedown" mouseDownDecoder
    ]
      (renderSvgLines model)


renderSvgLines : Model -> List (Svg.Svg msg)
renderSvgLines { clients } =
  List.concatMap .lines clients
    |> sortBy .id
    |> List.map renderLine


renderLine : Line -> Svg msg
renderLine line =
  let
      width =
        case line.color of
          "white" -> "60px"
          _ -> line.width

  in
      polyline
        [ attribute "stroke-linecap" "round"
        , attribute "stroke-linejoin" "round"
        , fill "none"
        , stroke line.color
        , strokeWidth width
        , List.map pointToString line.points
          |> join " "
          |> points
        ]
        []


pointToString : Point -> String
pointToString { x, y } = (toString x) ++ "," ++ (toString y)

