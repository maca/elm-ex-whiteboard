module Whiteboard.State exposing
  (init, initModel, update, subscriptions)


import Mouse exposing (Position)
import Window exposing (Size)
import Json.Decode as Decode
import List exposing (sortBy, foldl, length)

import Whiteboard.Types exposing (..)
import Whiteboard.Ports exposing (..)
import Whiteboard.Serialization exposing (..)


-- INIT
init : Flags -> ( Model, Cmd Msg )
init flags =
  ( initModel flags, Cmd.none )


initModel : Flags -> Model
initModel { clientId } =
  { clients = [initClient clientId]
  , windowSize = (Size 1279 704)
  , offset = Position 0 0
  , clientId = clientId
  , drawing = False
  }


initClient : String -> Client
initClient clientId =
  Client [] "black" "3px" clientId


-- UPDATE
addLine : Int -> Client -> Client
addLine id client =
  let
      line = (Line [] client.color client.width id)
  in
      { client | lines = line :: client.lines }


updateColor : String -> Client -> Client
updateColor color client = { client | color = color }


updateWidth : String -> Client -> Client
updateWidth width client = { client | width = width }


updateClient : Model -> Client -> (Client -> Client) -> Model
updateClient model { id } updateFn =
  { model | clients =
      updateFirst (\c -> c.id == id) updateFn model.clients }


batchUpdateClient : Model -> Client -> (List (Client -> Client)) -> Model
batchUpdateClient model client updates =
  let
      updateFn client = foldl (\fn md -> fn md) client updates
  in
      updateClient model client updateFn


addPoint : Point -> Client -> Client
addPoint point client =
  let
      predicate ln = ln.id == point.lineId
      fn ln = { ln | points = point::ln.points }
  in
      { client | lines = updateFirst predicate fn client.lines }


addSortedPoint : Point -> Client -> Client
addSortedPoint point client =
  let
      predicate ln = ln.id == point.lineId
      fn ln = { ln | points = point::ln.points |> sortBy .id }
  in
      { client | lines = updateFirst predicate fn client.lines }


newPoint : Position -> Position -> Client -> Maybe Point
newPoint { x, y } off { lines } =
  case lines of
    { id, points } :: tail ->
      Just (Point (x - off.x) (y - off.y) (length points) id)
    [] ->
      Nothing


updateRemoteClient : Client -> Model -> List (Client -> Client) -> Model
updateRemoteClient client model batch =
  case findById client.id model.clients of
    Just _ ->
      batchUpdateClient model client batch

    Nothing ->
      let
          model2 = { model | clients = client :: model.clients }
      in
          updateRemoteClient client model2 batch


copyLines : Client -> Client -> Client
copyLines client { lines } =
  { client | lines = lines }


addRemoteLine : Point -> Client -> Client
addRemoteLine { lineId } client =
  case findById lineId client.lines of
    Just _  -> client
    Nothing -> addLine lineId client


addRemotePoint : Client -> Point -> Model -> Model
addRemotePoint client point model =
  [copyLines client, addRemoteLine point, addSortedPoint point]
    |> updateRemoteClient client model


addRemotePoints : (List ( Client, Point )) -> Model -> Model
addRemotePoints points model =
  let
      updateFn (client, point) model =
        [copyLines client, addRemoteLine point, addPoint point]
          |> updateRemoteClient client model
  in
      foldl updateFn model points


getLocalClient : Model -> Client
getLocalClient model =
  case findById model.clientId model.clients of
    Just client ->
      client
    Nothing ->
      initClient model.clientId


decodingFailed : Model -> String -> ( Model, Cmd Msg )
decodingFailed model str =
  ( model, Cmd.none )


startDrawing : Position -> Client -> Model -> Model
startDrawing offset client model =
  let
      id     = foldl (\c acc -> acc + length c.lines) 0 model.clients
      model2 = updateClient model client (addLine id)

  in
      { model2 | drawing = True, offset = offset }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let
      localClient       = getLocalClient model
      updateLocalClient = updateClient model localClient

  in
      case msg of
        Draw position ->
          case newPoint position model.offset localClient of
            Just point ->
              ( updateLocalClient (addPoint point)
              , pointEncoder localClient point |> sendPoint
              )
            Nothing ->
              ( model, Cmd.none )

        AddLine offset ->
          ( startDrawing offset localClient model, Cmd.none)

        StopDrawing _ ->
          ( { model | drawing = False }, Cmd.none )

        UpdateColor color ->
          ( updateLocalClient (updateColor color), Cmd.none )

        UpdateWidth width ->
          ( updateLocalClient (updateWidth width), Cmd.none )

        Resize size ->
          ( { model | windowSize = size }, Cmd.none )

        ReceivePoint raw ->
          case Decode.decodeValue pointDataDecoder raw of
            Ok ( client, point ) ->
              ( addRemotePoint client point model, Cmd.none )

            Err str ->
              decodingFailed model str

        ReceivePoints raw ->
          case Decode.decodeValue pointsDataDecoder raw of
            Ok points ->
              ( addRemotePoints points model, Cmd.none )

            Err str ->
              decodingFailed model str


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [
    if model.drawing then Mouse.moves Draw else Sub.none
    , Mouse.ups StopDrawing
    -- , Window.resizes Resize
    , receivePoint ReceivePoint
    , receivePoints ReceivePoints
    ]


-- UTILS
find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        first :: rest ->
            if predicate first then
                Just first
            else
                find predicate rest

        [] ->
            Nothing


findById : a -> (List { b | id : a }) -> Maybe { b | id : a }
findById id list =
  find (\a -> a.id == id) list


updateFirst : (a -> Bool) -> (a -> a) -> List a -> List a
updateFirst predicate fn list =
  case list of
    head :: tail ->
      if predicate head then
        (fn head) :: tail
      else
        head :: (updateFirst predicate fn tail)

    [] ->
      []

