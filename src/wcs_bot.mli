open Wcs_t

val bypass_default : string -> (bool * 'a) option
val before_default : message_request -> message_request
val after_default : message_response -> message_response
val user_input_default : unit -> string
val matcher_default : message_response -> 'a option
val call :
  ?bypass:(string -> (bool * json) option) ->
  ?before:(message_request -> message_request) ->
  ?after:(message_response -> message_response) ->
  ?user_input:(unit -> string) ->
  credential -> action -> string * json

val get_value :
  ?bypass:(string -> (bool * 'a) option) ->
  ?before:(message_request -> message_request) ->
  ?after:(message_response -> message_response) ->
  ?user_input:(unit -> string) ->
  ?matcher:(message_response -> 'a option) ->
  credential -> string -> json -> string -> string * 'a
