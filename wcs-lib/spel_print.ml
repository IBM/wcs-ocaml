(*
 *  This file is part of the Watson Conversation Service OCaml API project.
 *
 * Copyright 2016-2017 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

open Spel_t

(* Eval functions *)
let print_lit (istop:bool) v : string =
  begin match v with
  | L_string s -> if istop then s else "'" ^ s ^ "'"
  | L_int n -> string_of_int n
  | L_real n -> string_of_float n
  | L_boolean b -> if b then "true" else "false"
  | L_null -> "null"
  end

let print_type t : string =
  begin match t with
  | T_string -> "String"
  | T_int -> "int"
  | T_real -> "double"
  | T_boolean -> "boolean"
  | T_object -> "Object"
  end

let print_op (op: Spel_t.op) (l: string list) : string =
  begin match op, l with
  | Op_eq, [v1; v2] -> v1 ^ " == " ^ v2
  | Op_ne, [v1; v2] -> v1 ^ " != " ^ v2
  | Op_lt, [v1; v2] -> v1 ^ " < " ^ v2
  | Op_le, [v1; v2] -> v1 ^ " <= " ^ v2
  | Op_gt, [v1; v2] -> v1 ^ " > " ^ v2
  | Op_ge, [v1; v2] -> v1 ^ " >= " ^ v2
  | Op_not, [v] -> "!(" ^ v ^ ")"
  | Op_and, [v1; v2] -> v1 ^ " and " ^ v2
  | Op_or, [v1; v2] -> v1 ^ " or " ^ v2
  | Op_plus, [v1; v2] -> v1 ^ " + " ^ v2
  | Op_minus, [v1; v2] -> v1 ^ " - " ^ v2
  | Op_mult, [v1; v2] -> v1 ^ " * " ^ v2
  | Op_div, [v1; v2] -> v1 ^ " / " ^ v2
  | Op_mod, [v1; v2] -> v1 ^ " % " ^ v2
  | Op_pow, [v1; v2] -> v1 ^ " ** " ^ v2
  | Op_concat, [v1; v2] -> v1 ^ " + " ^ v2
  | Op_toString, [v1] -> v1 ^ ".toString()"
  | _ -> "[bad number of arguments]"
  end

let print_dim dim =
  begin match dim with
  | Some d -> "[" ^ (string_of_int d) ^ "]"
  | None -> "[]"
  end

let print_dims dims : string =
  String.concat "" (List.map print_dim dims)

let escape (istop:bool) s =
  if istop then "<?"^s^"?>" else s

let rec print_expr_aux (istop:bool) e : string =
  begin match e.expr_desc with
  | E_lit v -> print_lit istop v
  | E_conversation_start -> "conversation_start"
  | E_prop (e, x) -> escape istop ((print_expr_aux false e) ^ "." ^ x)
  | E_call (None, x, el) -> escape istop (x ^ "(" ^ (String.concat "," (List.map (print_expr_aux false) el)) ^ ")")
  | E_call (Some e, x, el) -> escape istop ((print_expr_aux false e) ^ "." ^ x ^ "(" ^ (String.concat "," (List.map (print_expr_aux false) el)) ^ ")")
  | E_get_array (e, e_n) -> escape istop ((print_expr_aux false e) ^ "[" ^ (print_expr_aux false e_n) ^ "]")
  | E_get_dictionary (e, e_x) -> escape istop ((print_expr_aux false e) ^ "[" ^ (print_expr_aux false e_x) ^ "]")
  | E_list l -> escape istop ("{"  ^ (String.concat "," (List.map (print_expr_aux false) l)) ^ "}")
  | E_new_array (t, dims, Some init) -> escape istop ("new " ^ (print_type t) ^ (print_dims dims) ^ "{" ^ (String.concat "," (List.map (print_expr_aux false) init)) ^ "}")
  | E_new_array (t, dims, None) -> escape istop ("new " ^ (print_type t) ^ (print_dims dims))
  | E_op (Op_concat, [e1; e2]) -> if istop then (print_expr_aux istop e1) ^ (print_expr_aux istop e2) else (print_expr_aux istop e1) ^ " + " ^ (print_expr_aux istop e2)
  | E_op (op, l) -> escape istop (print_op op (List.map (print_expr_aux false) l))
  | E_conditional (e1,e2,e3) -> (print_expr_aux istop e1) ^ "?" ^ (print_expr_aux istop e2) ^ ":" ^ (print_expr_aux istop e3)
  | E_variable x -> "$" ^ x
  | E_intent x -> "#" ^ x
  | E_entities -> "entities"
  | E_entity (x, None) -> "@" ^ x
  | E_entity (x, Some y) -> "@" ^ x ^ ":" ^ y
  | E_error j -> "[ERROR]"
  | E_input -> "input"
  end

let lift_constants e = `String e

let print_expr istop e =
  lift_constants (print_expr_aux istop e)

(* Top level eval for conditions *)
let print_expr_cond e : string = print_expr_aux false e

(* Top level eval for body *)
let print_expr_text e = print_expr_aux true e

(* Top level eval for context *)
let rec unexpr_expr_var j =
  begin match j with
  | `Assoc l -> `Assoc (List.map (fun x -> (fst x, unexpr_expr_var (snd x))) l)
  | `Bool b -> `Bool b
  | `Float f -> `Float f
  | `Int i -> `Int i
  | `List l -> `List (List.map unexpr_expr_var l)
  | `Null -> `Null
  | `Expr e -> print_expr true e
  end

let print_expr_var j = unexpr_expr_var j

let print_expr_context context_expr : Yojson.Basic.json =
  `Assoc (List.map (fun x -> (fst x, print_expr_var (snd x))) context_expr)

