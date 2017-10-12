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

type location = Lexing.position * Lexing.position

type spel_type =
  | T_string
  | T_int
  | T_real
  | T_boolean
  | T_object

type literal =
  | L_string of string
  (*| L_date of string *)
  | L_int of int
  | L_real of float
  | L_boolean of bool
  | L_null

type op =
  | Op_eq
  | Op_ne
  | Op_lt
  | Op_le
  | Op_gt
  | Op_ge
  | Op_not
  | Op_and
  | Op_or
  | Op_plus
  | Op_minus
  | Op_mult
  | Op_div
  | Op_mod
  | Op_pow
  | Op_concat
  | Op_toString
  (*| Op_instanceof *)
(*| Op_matches *)

type expression =
  { expr_desc : expression_desc;
    expr_loc : location;
    mutable expr_text : string option }
and expression_desc =
  | E_lit of literal
  | E_conversation_start
  | E_prop of expression * string    (* e.x *)
  | E_get_array of expression * expression  (* e[n] *)
  | E_get_dictionary of expression * expression (* e['x'] *)
  | E_list of expression list
  | E_new_array of spel_type * int option list * expression list option
  | E_call of expression option * string * expression list (* e.m() *)
  | E_op of op * expression list
  (*| E_assign of string * expression *)
  (*| E_type of string *)
  (*| E_constructor *)
  | E_conditional of expression * expression * expression
  | E_variable of string
  | E_intent of string
  | E_entities
  | E_entity of (string * string option)
  | E_error of Yojson.Safe.json
  | E_input

(** JSON with embedded expressions *)
type json_expr = [
    `Assoc of (string * json_expr) list
  | `Bool of bool
  | `Float of float
  | `Int of int
  | `List of json_expr list
  | `Null
  | `Expr of expression
]

(** Toplevel Expressions *)
type expression_definition =
  | Expr_condition of expression
  | Expr_text of expression
  | Expr_context of (string * json_expr) list

