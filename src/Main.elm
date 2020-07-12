module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, label, li, ol, p, text)
import Html.Attributes exposing (attribute, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


type alias Model =
    { intervalSeconds : Int
    , maxAttempts : Int
    , backoffRate : Int
    , times : List Int
    }


initialModel : Model
initialModel =
    { intervalSeconds = 1
    , maxAttempts = 3
    , backoffRate = 2
    , times = []
    }
        |> calculateTimes


type Msg
    = ChangeIntervalSeconds String
    | ChangeMaxAttempts String
    | ChangeBackoffRate String


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeIntervalSeconds newIntervalSeconds ->
            if newIntervalSeconds == "" then
                { model | intervalSeconds = 0 } |> calculateTimes

            else
                case String.toInt newIntervalSeconds of
                    Nothing ->
                        model

                    Just val ->
                        { model | intervalSeconds = val } |> calculateTimes

        ChangeMaxAttempts newMaxAttempts ->
            if newMaxAttempts == "" then
                { model | maxAttempts = 0 } |> calculateTimes

            else
                case String.toInt newMaxAttempts of
                    Nothing ->
                        model

                    Just val ->
                        { model | maxAttempts = val } |> calculateTimes

        ChangeBackoffRate newBackoffRate ->
            if newBackoffRate == "" then
                { model | backoffRate = 0 } |> calculateTimes

            else
                case String.toInt newBackoffRate of
                    Nothing ->
                        model

                    Just val ->
                        { model | backoffRate = val } |> calculateTimes


calculateTimes : Model -> Model
calculateTimes model =
    if model.maxAttempts < 1 then
        { model | times = [] }

    else
        let
            values =
                List.repeat model.maxAttempts 0
                    |> List.indexedMap (\index _ -> model.intervalSeconds * model.backoffRate * index + model.intervalSeconds)
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
        , input [ attribute "class" "input", type_ "text", value (viewBlankForZeroElseNumber model.backoffRate), onInput ChangeBackoffRate ] []
        , div [] []
        , viewTimes model
        ]


viewBlankForZeroElseNumber : Int -> String
viewBlankForZeroElseNumber value =
    if value == 0 then
        ""

    else
        String.fromInt value


viewTimes model =
    div []
        [ p [ attribute "class" "mt-2" ] []
        , label [ attribute "class" "label" ] [ text "Times:" ]
        , div []
            [ div [] ([] ++ List.map viewTime model.times)
            ]
        , p [ attribute "class" "mt-2" ] []
        , label [ attribute "class" "label" ] [ text ("Total: " ++ String.fromInt (List.foldl (\time acc -> time + acc) 0 model.times) ++ " seconds") ]
        ]


viewTime : Int -> Html msg
viewTime time =
    if time > 1 then
        div [] [ text ("- " ++ String.fromInt time ++ " seconds") ]

    else
        div [] [ text ("- " ++ String.fromInt time ++ " second") ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
