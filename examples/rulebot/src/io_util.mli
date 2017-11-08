val slack_io : bool ref
val set_slack_io : unit -> unit

val set_slack_log : string -> unit
val close_slack_log : unit -> unit

val pretty_json_string : string -> string

val print_rule : Cnl_t.cnl_rule -> unit

val print_workspace : string -> unit

val print_instr : int -> unit
val print_berl_error : string -> unit

val print_done : unit -> unit

val print_C : string -> unit
val print_output_stdout : Cnl_t.cnl_rule option -> string -> unit
val get_input_stdin : unit -> string

