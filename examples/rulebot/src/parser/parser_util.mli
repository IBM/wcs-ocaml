val string_of_file : string -> string

val parse : ('a -> Lexing.lexbuf -> 'b) -> 'a -> Lexing.lexbuf -> 'b
val parse_string : (Lexing.lexbuf -> 'a) -> string -> 'a
val parse_file : (Lexing.lexbuf -> 'a) -> string -> 'a
val parse_expr : Lexing.lexbuf -> Cnl_t.cnl_expr
val parse_cnl_expr_from_string : string -> Cnl_t.cnl_expr
val parse_rule : Lexing.lexbuf -> Cnl_t.cnl_rule
val parse_cnl_rule_from_string : string -> Cnl_t.cnl_rule
val parse_bmd_spec : Lexing.lexbuf -> Bmd_t.bmd_spec
val parse_bmd_spec_from_string : string -> Bmd_t.bmd_spec
val parse_bmd_spec_from_file : string -> Bmd_t.bmd_spec
