module Update.Deep.Form exposing (Model, Msg, init, reset, setDisabled, update)

import Form exposing (Form)
import Form.Field exposing (Field)
import Form.Validate exposing (Validation)
import Update.Deep exposing (..)


type alias Msg =
    Form.Msg


type alias Model a b =
    { form : Form a b
    , disabled : Bool
    , validation : Validation a b
    }


insertAsFormIn : Model a b -> Form a b -> Update (Model a b) msg c
insertAsFormIn model form =
    save { model | form = form }


setDisabled : Bool -> Model a b -> Update (Model a b) msg c
setDisabled disabled state =
    save { state | disabled = disabled }


init : List ( String, Field ) -> Validation a b -> Update (Model a b) msg c
init fields validation =
    Update.Deep.map3 Model
        (Form.initial fields validation |> save)
        (save False)
        (save validation)


reset : List ( String, Field ) -> Model a b -> Update (Model a b) msg c
reset fields model =
    Form.initial fields model.validation
        |> insertAsFormIn model
        |> andThen (setDisabled False)


update : { onSubmit : b -> c } -> Form.Msg -> Model a b -> Update (Model a b) msg c
update { onSubmit } msg model =
    case ( msg, Form.getOutput model.form ) of
        ( Form.Submit, Just form ) ->
            model
                |> setDisabled True
                |> andApplyCallback (onSubmit form)

        _ ->
            model.form
                |> Form.update model.validation msg
                |> insertAsFormIn model
