open Wcs_t
open Cnl_t
open Call_t

val null : json

val set : json -> string -> json -> json
val take : json -> string -> json * json option
val get : json -> string -> json option

val set_skip_user_input : json -> bool -> json
val take_skip_user_input : json -> json * bool

val set_call : json -> call -> json
val take_call : json -> json * call option

val set_return : json -> json -> json
val get_return : json -> json option

val set_rule : json -> string -> cnl_rule -> json
val get_rule : json -> string -> cnl_rule option

val set_expr : json -> string -> cnl_expr -> json
val get_expr : json -> string -> cnl_expr option

val set_evnt_desc : json -> string -> cnl_evnt_desc -> json
val get_evnt_desc : json -> string -> cnl_evnt_desc option

val set_cond_desc : json -> string -> cnl_cond_desc -> json
val get_cond_desc : json -> string -> cnl_cond_desc option

val set_actns_desc : json -> string -> cnl_actns_desc -> json
val get_actns_desc : json -> string -> cnl_actns_desc option

val set_actn_desc : json -> string -> cnl_actn_desc -> json
val get_actn_desc : json -> string -> cnl_actn_desc option

val set_bool : json -> string -> bool -> json
val get_bool : json -> string -> bool option

val set_string : json -> string -> string -> json
val get_string : json -> string -> string option
val take_string : json -> string -> json * string option

val set_dispatch : json -> string -> string Dialog_util.dispatch -> json
val get_dispatch : json -> string -> int Dialog_util.dispatch option

val build_cnl : cnl_kind -> int -> string -> json
