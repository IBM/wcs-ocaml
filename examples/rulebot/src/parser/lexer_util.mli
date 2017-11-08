exception LexError of string
val string_buff : unit -> Buffer.t
val reset_string : Buffer.t -> unit
val add_char_to_string : Buffer.t -> char -> unit
val get_string : Buffer.t -> string
