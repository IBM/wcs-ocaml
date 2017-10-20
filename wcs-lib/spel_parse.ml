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
open Spel_sedlexer_j

exception LexError of string

let error default msg = Log.error "Spel parsing" default msg
let warning default msg = Log.warning "Spel parsing" msg; default

type state = BodyLexing | ExprLexing

(** {6 Expression lexer} *)
let expr_lexer buff lb =
  Spel_sedlexer_j.token buff lb

let mk_expr_lexer () =
  expr_lexer (Spel_util.string_buff ())

(** {6 Body lexer} *)
let body_lexer st buff lb =
  begin match !st with
  | BodyLexing ->
      let tk = Spel_sedlexer_j.body buff lb in
      begin match tk with
      | Spel_parser_j.OPENEXPR _ -> st := ExprLexing ; tk
      | _ -> tk
      end
  | ExprLexing ->
      let tk = Spel_sedlexer_j.token buff lb in
      begin match tk with
      | Spel_parser_j.CLOSEEXPR -> st := BodyLexing ; tk
      | _ -> tk
      end
  end

let mk_body_lexer () =
  body_lexer (ref BodyLexing) (Spel_util.string_buff ())

(** {6 Parsers} *)
let fix_empty_condition ocond =
  begin match ocond with
  | Some cond -> cond
  | None -> Spel_util.mk_expr (E_lit (L_boolean false))
  end

let expression_from_file f =
  fix_empty_condition
    (Spel_util.uparse_file
       Spel_parser_j.condition_main (mk_expr_lexer ()) f)

let expression_from_string s =
  begin try
    let parsed =
      Spel_util.uparse_string
        Spel_parser_j.condition_main
        (mk_expr_lexer ())
        s
    in
    let ast = fix_empty_condition parsed in
    ast.expr_text <- Some s;
    ast
  with
  | LexError msg ->
      warning (Spel_util.mk_expr_text (E_error msg) (Some s))
        (Format.sprintf "[%s] in expression: '%s'" msg s)
  | _ ->
      warning
        (Spel_util.mk_expr_text
           (E_error "Parse error in expression")
           (Some s))
        (Format.sprintf "error in expression: '%s'" s)
  end

let expression_from_text_file f =
  Spel_util.uparse_file Spel_parser_j.body_main (mk_body_lexer ()) f

let expression_from_text_string s =
  begin try
    let ast =
      Spel_util.uparse_string
        Spel_parser_j.body_main
        (mk_body_lexer ())
        s
    in
    ast.expr_text <- Some s;
    ast
  with
  | LexError msg ->
      warning
        (Spel_util.mk_expr_text (E_error msg) (Some s))
        (Format.sprintf "[%s] in text: '%s'" msg s)
  | _ ->
      warning
        (Spel_util.mk_expr_text (E_error "Parse error in text") (Some s))
        (Format.sprintf "in text: '%s'" s)
  end

(** {6 JSON AST with embedded Spel expressions} *)
let rec json_expression_from_json (j:Json_t.json) : json_expression =
  begin match j with
  | `Assoc l ->
      `Assoc (List.map (fun x -> (fst x, json_expression_from_json (snd x))) l)
  | `Bool b -> `Bool b
  | `Float f -> `Float f
  | `Int i -> `Int i
  | `List l -> `List (List.map json_expression_from_json l)
  | `Null -> `Null
  | `String s -> `Expr (expression_from_text_string s) (* This catches parse errors at the expression level *)
  end
