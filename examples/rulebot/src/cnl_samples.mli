open Cnl_t

val rule_init : unit -> cnl_rule
val cond_init : unit -> cnl_cond_desc
val actns_init : unit -> cnl_actns_desc
val print_init : unit -> cnl_actn_desc
val emit_init : unit -> cnl_actn_desc
val define_init : variable_name -> cnl_actn_desc
val set_init : field_name -> variable_name -> cnl_actn_desc
val define1 : cnl_action
val emit1 : cnl_action
val when1 : string * string option
val cond1 : cnl_cond_desc
val then1 : cnl_action node_list
val rule1 : cnl_rule
val define21 : cnl_action
val define22 : cnl_action
val setdesc21 : cnl_actn_desc
val setdesc22 : cnl_actn_desc
val set21 : cnl_action
val set22 : cnl_action
val rule2 : cnl_rule
val cnl_samples : (string * cnl_rule) list
val expr1 : cnl_expr
val expr2 : cnl_expr
