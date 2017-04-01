open Wcs_t

val null : json

val set : json -> string -> json -> json
val take : json -> string -> json * json option
val get : json -> string -> json option

val set_skip_user_input : json -> bool -> json
val take_skip_user_input : json -> json * bool

val set_actions : json -> action list -> json
val take_actions : json -> json * action list option

val push_action : json -> action -> json
val pop_action : json -> json * action option

val set_return : json -> json -> json
val get_return : json -> json option

val set_bool : json -> string -> bool -> json
val get_bool : json -> string -> bool option

val set_string : json -> string -> string -> json
val get_string : json -> string -> string option
val take_string : json -> string -> json * string option
