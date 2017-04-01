exception Error of string * string

val error_recovery : bool ref
(** Set if we should avoid to fail in case of error. *)

val error : string -> 'a option -> string -> 'a

(** [error module_name default msg] raises [Error]. If a default value
    is provided and [error_recovery] is [true], it returns the value
    instead of raising the exception [Error]. In this case, the error
    message is printed.
 *)

val print_error : string -> string -> unit
(** [print_error module_name msg] prints the error message [msg]
    prefixed with the module name [module_name].
*)

val warning : string -> string -> unit
(** [warning module_name msg] prints the warning message [msg] prefixed
    with the module name [module_name].
 *)

val debug_message : bool ref
(** Set if we should display debug. *)

val debug : string -> string -> unit
(** [debug module_name msg] prints the debug message [msg] prefixed
    with the module name [module_name].
 *)
