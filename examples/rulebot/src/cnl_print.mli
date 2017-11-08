open Cnl_t

val cnl_print_kind : cnl_kind -> string
val cnl_print_expr_top : Format.formatter -> cnl_expr -> unit
val cnl_print_rule : Format.formatter -> cnl_rule -> unit
val cnl_print_rule_top : cnl_rule -> string

