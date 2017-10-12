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

open Spel_util
open Spel_parser_j

let keyword_table =
  let tbl = Hashtbl.create 37 in
  begin
    List.iter (fun (key, data) -> Hashtbl.add tbl key data)
      [ "or", OR;
        "and", AND;
        "not", NOT;
        "true", TRUE;
        "anything_else", ANYTHING_ELSE;
        "false", FALSE;
        "null", NULL;
        "conversation_start", CONVERSATION_START;
        "input", INPUT;
        "entities", ENTITIES;
        (* "output", OUTPUT; *)
      ]; tbl
  end

let uident = [%sedlex.regexp? Plus (id_continue|'-')]
let uintent = [%sedlex.regexp? Plus (id_continue|'-')]
let newline = [%sedlex.regexp? ('\010' | '\013' | "\013\010")]

let letter = [%sedlex.regexp? 'A'..'Z'|'a'..'z'|'_']
let ident_char = [%sedlex.regexp? 'A'..'Z'|'a'..'z'|'_'|'-'|'\''|'0'..'9']
let ident = [%sedlex.regexp? (letter, Star ident_char)]

let digit = [%sedlex.regexp? '0'..'9']
let frac = [%sedlex.regexp? '.', Star digit]
let exp = [%sedlex.regexp? ('e'|'E'), ('-'|'+'), Plus digit]
let integ = [%sedlex.regexp? Opt '-', Star digit]
let float = [%sedlex.regexp? Opt '-', Star digit, ((frac, Opt exp) | exp)]

let rec token sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | eof -> EOF ""
  | "==" -> EQUALEQUAL
  | "!=" -> NOTEQUAL
  | "<" -> LT
  | "<=" -> LTEQ
  | ">" -> GT
  | ">=" -> GTEQ
  | "&&" -> AND
  | "||" -> OR
  | "!" -> NOT
  | "." -> DOT
  | "?" -> QUESTION
  | ":" -> COLON
  | "," -> COMMA
  | "(" -> LPAREN
  | ")" -> RPAREN
  | "[" -> LBRACKET
  | "]" -> RBRACKET
  | "+" -> PLUS
  | "-" -> MINUS
  | ' ' | '\t' -> token sbuff lexbuf
  | newline -> (* Sedlexing.new_line lexbuf; *) token sbuff lexbuf
  | float -> REAL (float_of_string (Sedlexing.Utf8.lexeme buf))
  | integ -> INT (int_of_string (Sedlexing.Utf8.lexeme buf))
  | '"' -> reset_string sbuff; STRING (string sbuff lexbuf)
  | "'" -> reset_string sbuff; STRING (qstring sbuff lexbuf)
  | "#" -> intent sbuff lexbuf
  | "@" -> entity sbuff lexbuf
  | "$" -> VAR (variable sbuff lexbuf)
  | ident ->
      let s = Sedlexing.Utf8.lexeme buf in
      begin try Hashtbl.find keyword_table s
      with Not_found -> IDENT s
      end
  | "?>" -> reset_string sbuff; CLOSEEXPR
  | any -> failwith "Unexpected character"
  | _ -> failwith "Unexpected character"
  end

and intent sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | uintent -> INTENT (Sedlexing.Utf8.lexeme buf)
  | _ -> failwith "Unexpected character after '#'"
  end

and entity sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | uident -> entity_rest sbuff (Sedlexing.Utf8.lexeme buf) lexbuf
  | _ -> failwith "Unexpected character after '#'"
  end

and entity_rest sbuff entity_name lexbuf =
  let buf = lexbuf.stream in
  begin match %sedlex buf with
  | ':' -> entity_value sbuff entity_name lexbuf
  | _ -> ENTITY (entity_name,None)
  end

and entity_value sbuff entity_name lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | uident -> ENTITY (entity_name, Some (Sedlexing.Utf8.lexeme buf))
  | '(' ->
      reset_string sbuff;
      ENTITY (entity_name, Some (qparen sbuff lexbuf))
  | _ -> failwith "Unexpected character after ':'"
  end

and variable sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | ident -> Sedlexing.Utf8.lexeme buf
  | _ -> failwith "Unexpected character after '#'"
  end

and string sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | '"' -> get_string sbuff
  | any -> add_string_to_string sbuff (Sedlexing.Utf8.lexeme buf); string sbuff lexbuf
  | _ -> failwith "Unexpected character"
  end

and qstring sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | "'" -> get_string sbuff
  | any -> add_string_to_string sbuff (Sedlexing.Utf8.lexeme buf); qstring sbuff lexbuf
  | _ -> failwith "Unexpected character"
  end

and qparen sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | ")" -> get_string sbuff
  | any -> add_string_to_string sbuff (Sedlexing.Utf8.lexeme buf); qparen sbuff lexbuf
  | _ -> failwith "Unexpected character"
  end

and body sbuff lexbuf =
  let buf = lexbuf.stream in
  begin match%sedlex buf with
  | "\\$" -> add_string_to_string sbuff "\\$"; body sbuff lexbuf
  | "$" -> let s = get_string sbuff in reset_string sbuff; BODYVAR (s,variable sbuff lexbuf)
  | eof -> let s = get_string sbuff in EOF s (* End of string *)
  | "<?" -> let s = get_string sbuff in reset_string sbuff; OPENEXPR s  (* End of string *)
  | any -> add_string_to_string sbuff (Sedlexing.Utf8.lexeme buf); body sbuff lexbuf
  | _ -> failwith "Unexpected character"
  end

