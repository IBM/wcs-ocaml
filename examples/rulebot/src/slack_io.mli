open Cnl_t

val launch :
    string ->
      ((unit -> string) * (cnl_rule option -> string -> unit))
