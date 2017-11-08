open Cnl_t

type cnl_instr =
  | I_repl_expr of int * cnl_expr_desc (* Replace at focus *)
  | I_repl_actn of int * cnl_actn_desc
  | I_repl_evnt of int * cnl_evnt_desc
  | I_repl_cond of int * cnl_cond_desc
  | I_repl_actns of int * cnl_actns_desc
  | I_repl_actns_closed of int * bool
  | I_conf_expr of int * bool          (* Confirm at focus *)
  | I_conf_actn of int * bool
  | I_conf_evnt of int * bool
  | I_conf_cond of int * bool
  | I_conf_actns of int * bool
  | I_conf_rule of int * bool
  | I_insr_actn                   (* Insert action *)

type cnl_program = cnl_instr list

val focus_of_instr : cnl_instr -> int

(* JSON export/import *)
val cnl_instr_of_yojson : Json_t.safe -> (cnl_instr, string) Deriving_intf.deriving_result
val cnl_instr_to_yojson : cnl_instr -> Json_t.safe

val cnl_program_of_yojson : Json_t.safe -> (cnl_program, string) Deriving_intf.deriving_result
val cnl_program_to_yojson : cnl_program -> Json_t.safe

