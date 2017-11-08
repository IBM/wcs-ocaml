(** Utilities for CNL lexing *)

exception LexError of string

let string_buff () = Buffer.create 256
let reset_string buff = Buffer.clear buff
let add_char_to_string buff c = Buffer.add_char buff c
let get_string buff = Buffer.contents buff

