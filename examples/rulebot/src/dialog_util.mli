open Cnl_t

type workspace_ids = {
    ws_dispatch_id : string;
    ws_when_id : string;
    ws_cond_id : string;
    ws_cond_continue_id : string;
    ws_then_id : string;
    ws_expr_id : string;
    ws_actn_id : string;
    ws_accept_id : string;
  }

type 'a dispatch = {
    dsp_replace : bool;
    dsp_abort : bool;
    dsp_number : 'a option;
    dsp_when : bool;
    dsp_cond : bool;
    dsp_then : bool;
  }

val bypass_expr : string -> (bool * cnl_expr) option
val bypass_empty : string -> (bool * 'a) option

val match_string : string -> (string * string) option

val debug_message : Wcs_t.message_request -> Wcs_t.message_response -> unit

(** {6 JSON serialization} *)
val dispatch_of_yojson :
    (Json_t.safe -> 'a Deriving_intf.deriving_error_or) ->
      Json_t.safe -> ('a dispatch, string) Deriving_intf.deriving_result
val dispatch_to_yojson :
    ('a -> Json_t.safe) -> 'a dispatch -> Json_t.safe

val int_dispatch_of_yojson :
    Json_t.safe -> (int dispatch, string) Deriving_intf.deriving_result

val string_dispatch_to_yojson : string dispatch -> Json_t.safe
