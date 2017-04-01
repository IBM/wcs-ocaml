open Wcs_t

exception Error of string

val message : credential ->
  string -> message_request -> message_response

val get_workspace : credential ->
  string -> workspace

val update_workspace : credential ->
  string -> workspace -> unit

val create_workspace : credential ->
  workspace -> create_response

val delete_workspace : credential ->
  string -> unit
