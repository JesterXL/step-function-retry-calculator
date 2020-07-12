module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, label, li, ol, p, text)
import Html.Attributes exposing (attribute, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onBlur)
import Round
import Debug

type alias Model =
    { intervalSeconds : Int
    , maxAttempts : Int
    , backoffRateText : String
    , backoffRate : Float
    , times : List Float
    }


initialModel : Model
initialModel =
    { intervalSeconds = 1
    , maxAttempts = 3
    , backoffRateText = "2.0"
    , backoffRate = 2.0
    , times = []
    }
        |> calculateTimes


type Msg
    = ChangeIntervalSeconds String
    | ChangeMaxAttempts String
    | ChangeBackoffRateText String


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeIntervalSeconds newIntervalSeconds ->
            { model | intervalSeconds = parseIntElseBlankIsZero model.intervalSeconds newIntervalSeconds } |> calculateTimes

        ChangeMaxAttempts newMaxAttempts ->
            { model | maxAttempts = parseIntElseBlankIsZero model.maxAttempts newMaxAttempts } |> calculateTimes

        ChangeBackoffRateText text ->
            if text == "" then
                { model | backoffRateText = text, backoffRate = 0.0 } |> calculateTimes

            else
                case String.toFloat text of
                    Nothing ->
                        { model | backoffRateText = text }

                    Just val ->
                        { model | backoffRateText = text, backoffRate = val } |> calculateTimes


parseIntElseBlankIsZero : Int -> String -> Int
parseIntElseBlankIsZero current string =
    if string == "" then
        0
    else
        case String.toInt string of
            Nothing ->
                current

            Just value ->
                value

calculateTimes : Model -> Model
calculateTimes model =
    if model.maxAttempts < 1 then
        { model | times = [] }

    else
        let
            values =
                List.repeat model.maxAttempts 0
                    |> List.indexedMap (\index _ -> (toFloat model.intervalSeconds) * model.backoffRate * (toFloat index) + (toFloat model.intervalSeconds))
        in
        { model | times = values }


view : Model -> Html Msg
view model =
    div []
        [ label [ attribute "class" "label" ] [ text "Interval Seconds:" ]
        , input [ attribute "class" "input", type_ "text", value (viewBlankForZeroElseNumber model.intervalSeconds), onInput ChangeIntervalSeconds ] []
        , label [ attribute "class" "label" ] [ text "Max Attempts:" ]
        , input [ attribute "class" "input", type_ "text", value (viewBlankForZeroElseNumber model.maxAttempts), onInput ChangeMaxAttempts ] []
        , label [ attribute "class" "label" ] [ text "Backoff Rate:" ]
        , input [ attribute "class" "input", type_ "text", value model.backoffRateText, onInput ChangeBackoffRateText ] []
        , div [] []
        , viewTimes model
        ]


viewBlankForZeroElseNumber : Int -> String
viewBlankForZeroElseNumber value =
    if value == 0 then
        ""

    else
        String.fromInt value

viewFloatBlankForZeroElseNumber : Float -> String
viewFloatBlankForZeroElseNumber value =
    if value == 0 then
        ""

    else
        String.fromFloat value


viewTimes model =
    div []
        [ p [ attribute "class" "mt-2" ] []
        , label [ attribute "class" "label" ] [ text "Times:" ]
        , div []
            [ div [] ([] ++ List.map viewTime model.times)
            ]
        , p [ attribute "class" "mt-2" ] []
        , label [ attribute "class" "label" ] [ text (formatTotal model.times) ]
        ]

formatTotal : List Float -> String
formatTotal times =
    let
        total =
            List.foldl (\time acc -> time + acc) 0.0 times
        totalString = Round.round 1 total
    in
    "Total: "
    ++ totalString 
    ++ " "
    ++ (secondOrSeconds (round total))

viewTime : Float -> Html msg
viewTime time =
    div [] [ text ("- " ++ (Round.round 1 time) ++ " " ++ (secondOrSeconds (round time))) ]



secondOrSeconds : Int -> String
secondOrSeconds value =
    if value > 1 then "seconds" else "second"

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
