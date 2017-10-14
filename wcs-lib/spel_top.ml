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

let parse_spel_cond_from_file f =
  fix_empty_condition (Spel_util.uparse_file Spel_parser_j.condition_main (mk_expr_lexer ()) f)

let parse_spel_cond_from_string s =
  begin try
    let parsed = Spel_util.uparse_string Spel_parser_j.condition_main (mk_expr_lexer ()) s in
    let ast = fix_empty_condition parsed in
    ast.expr_text <- Some s;
    ast
  with
  | LexError msg ->
      error (Some (Spel_util.mk_expr (E_error (`String s))))
        (Format.sprintf "[%s] in condition: '%s'" msg s)
  | _ ->
      error (Some (Spel_util.mk_expr (E_error (`String s))))
        (Format.sprintf "[Parse error] in condition: '%s'" s)
  end

let parse_spel_text_from_file f =
  Spel_util.uparse_file Spel_parser_j.body_main (mk_body_lexer ()) f

let parse_spel_text_from_string s =
  begin try
    let ast = Spel_util.uparse_string Spel_parser_j.body_main (mk_body_lexer ()) s in
    ast.expr_text <- Some s;
    ast
  with
  | LexError msg ->
      error (Some (Spel_util.mk_expr (E_error (`String s))))
        (Format.sprintf "[%s] in text: '%s'" msg s)
  | _ ->
      error (Some (Spel_util.mk_expr (E_error (`String s))))
        (Format.sprintf "[Parse error] in text: '%s'" s)
  end

(** {6 JSON AST with embedded Spel expressions} *)
let rec build_spel_context_from_json (j:Yojson.Basic.json) : json_expression =
  begin try
    begin match j with
    | `Assoc l ->
        `Assoc (List.map (fun x -> (fst x, build_spel_context_from_json (snd x))) l)
    | `Bool b -> `Bool b
    | `Float f -> `Float f
    | `Int i -> `Int i
    | `List l -> `List (List.map build_spel_context_from_json l)
    | `Null -> `Null
    | `String s -> `Expr (parse_spel_text_from_string s)
    end
  with
  | LexError msg ->
      let expr = E_error (j :> Yojson.Safe.json) in
      error (Some (`Expr (Spel_util.mk_expr expr)))
        (Format.sprintf "[%s] in context: %s" msg (Yojson.Basic.to_string j))
  | _ ->
      error (Some (`Expr (Spel_util.mk_expr (E_error (j :> Yojson.Safe.json)))))
        (Format.sprintf "[Parse error] in context: %s" (Yojson.Basic.to_string j))
  end

let build_spel_context_from_context c : (string * json_expression) list =
  List.map (fun x -> (fst x, build_spel_context_from_json (snd x))) c
