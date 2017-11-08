open Cnl_t

type mode =
  | M_nothing
  | M_samples
  | M_script_samples
  | M_parse of string
  | M_script of string
  | M_wcs of string
  | M_ws_gen
  | M_ws_delete

val rulebot_mode : mode ref
val wcs_credential : Wcs_t.credential option ref
val workspaces_config : Dialog_interface_t.config option ref
val ws_update : bool ref
val is_slack : bool ref
val slackbot : string ref
val bom_io : string option ref
val load_io : string -> Io_t.io

val load_ws_ids : Wcs_t.credential ->
  Dialog_interface_t.config option ->
    bool -> string * Bmd_t.bmd_schema -> Dialog_util.workspace_ids

val bmd : string option ref
val args : (Arg.key * Arg.spec * Arg.doc) list
val anon_args : string -> unit
val usage : string
val main : unit -> unit
