module Main (..) where

import Html
import Html.Attributes
import Html.Events as Events
import StartApp
import Effects exposing (Effects)
import Task
import Http
import Json.Decode as Json exposing ((:=))


type AppState
  = Offline
  | Connecting
  | Connected


type Action
  = NoOp
  | Connect
  | Disconnect
  | OnGotUserList (Result Http.Error (List User))


type alias User =
  { id : Int
  , name : String
  }


type alias Model =
  { users : List User
  , state : AppState
  }


connButton : Signal.Address Action -> AppState -> Html.Html
connButton address state =
  let
    text =
      case state of
        Offline ->
          "Connect"

        Connecting ->
          "Connecting"

        Connected ->
          "Disconnect"

    classes =
      Html.Attributes.classList
        [ ( "button", True )
        , ( "connect", state == Offline )
        , ( "connecting", state == Connecting )
        , ( "disconnect", state == Connected )
        ]

    action =
      case state of
        Offline ->
          Connect

        Connecting ->
          NoOp

        Connected ->
          Disconnect
  in
    Html.a
      [ classes
      , Events.onClick address action
      , Html.Attributes.href "#"
      ]
      [ Html.text text ]


userList : List User -> Html.Html
userList users =
  Html.ul
    [ Html.Attributes.class "users" ]
    (List.map (\user -> Html.li [] [ Html.text user.name ]) users)


view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.div
    []
    [ connButton address model.state
    , userList model.users
    ]


init : ( Model, Effects Action )
init =
  ( { users = [], state = Offline }, Effects.none )


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
  case action of
    NoOp ->
      ( model, Effects.none )

    Connect ->
      ( { model | state = Connecting }, connectFx )

    Disconnect ->
      ( { model | state = Offline, users = [] }, Effects.none )

    OnGotUserList result ->
      let
        users =
          Result.withDefault [] result
      in
        ( { model | state = Connected, users = users }, Effects.none )


getUserListTask : Task.Task Http.Error (List User)
getUserListTask =
  Http.get decodeUsers "/json/users.json"


decodeUsers : Json.Decoder (List User)
decodeUsers =
  let
    user =
      Json.object2
        User
        ("id" := Json.int)
        ("name" := Json.string)
  in
    Json.list user


connectFx : Effects.Effects Action
connectFx =
  getUserListTask
    |> Task.toResult
    |> Task.map OnGotUserList
    |> Effects.task


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , inputs = []
    , update = update
    , view = view
    }


main : Signal Html.Html
main =
  app.html


port runner : Signal (Task.Task Effects.Never ())
port runner =
  app.tasks
