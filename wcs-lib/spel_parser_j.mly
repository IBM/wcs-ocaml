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

%{
open Spel_t
open Spel_util
%}

(* Literals *)
%token NULL
%token <int> INT
%token <float> REAL
%token <string> STRING

(* Variables and Entities *)
%token CONVERSATION_START
%token ANYTHING_ELSE
%token INPUT
%token ENTITIES

(* Identifiers *)
%token <string> IDENT                    (* foo *)
%token <string> INTENT                   (* #foo *)
%token <string * string option> ENTITY   (* @foo *)
%token <string> VAR                      (* $foo *)
%token <string * string> BODYVAR         (* $foo in a body *)
%token TRUE FALSE

(* Symbols and operators *)
%token AND OR NOT (* In Spel: 'and' 'or' '!' ; WCS also uses: '&&' '||' '!' *)
%token EQUALEQUAL NOTEQUAL
%token LT LTEQ GT GTEQ
%token DOT QUESTION COLON
%token COMMA
%token LPAREN RPAREN
%token LCURL RCURL
%token LBRACKET RBRACKET
%token PLUS MINUS
%token MULT DIV MOD
%token NEW
%token <string> EOF

(* Quoted expressions *)
%token <string> OPENEXPR
%token CLOSEEXPR

(* Priority *)
%nonassoc QUESTION COLON
%right OR
%right AND
%right EQUALEQUAL NOTEQUAL
%right LT LTEQ GT GTEQ
%right PLUS MINUS
%right MULT DIV MOD
%left NOT
%left LBRACKET
%left DOT
%nonassoc UMINUS

%start <Spel_t.expression> body_main
%start <Spel_t.expression option> condition_main

%%

condition_main:
| EOF
    { None }
| e = expr EOF
    { Some e }

expr:
(* Parenthesized pattern *)
| LPAREN e = expr RPAREN
    { e }
(* Literals *)
| NULL
    { mk_expr (E_lit L_null) }
| TRUE
    { mk_expr (E_lit (L_boolean true)) }
| FALSE
    { mk_expr (E_lit (L_boolean false)) }
| s = STRING
    { mk_expr (E_lit (L_string s)) }
| i = INT
    { mk_expr (E_lit (L_int i)) }
| f = REAL
    { mk_expr (E_lit (L_real f)) }
(* Special thingies *)
| CONVERSATION_START
    { mk_expr E_conversation_start }
| ANYTHING_ELSE (* Is just like true -- afaik *)
    { mk_expr (E_lit (L_boolean true)) }
| INPUT
    { mk_expr E_input }
| ENTITIES
    { mk_expr E_entities }
(* Identifiers *)
| id = IDENT
    { mk_expr (E_variable id) }
| id = VAR
    { mk_expr (E_variable id) }
| itt = INTENT
    { mk_expr (E_intent itt) }
| ent = ENTITY
    { mk_expr (E_entity ent) }

(* Operators *)
| NOT e1 = expr
    { mk_expr (E_op (Op_not, [e1])) }
| e1 = expr OR e2 = expr
    { mk_expr (E_op (Op_or, [e1;e2])) }
| e1 = expr AND e2 = expr
    { mk_expr (E_op (Op_and, [e1;e2])) }
| e1 = expr EQUALEQUAL e2 = expr
    { mk_expr (E_op (Op_eq, [e1;e2])) }
| e1 = expr NOTEQUAL e2 = expr
    { mk_expr (E_op (Op_ne, [e1;e2])) }
| e1 = expr PLUS e2 = expr
    { mk_expr (E_op (Op_plus, [e1;e2])) }
| e1 = expr MINUS e2 = expr
    { mk_expr (E_op (Op_minus, [e1;e2])) }
| e1 = expr MULT e2 = expr
    { mk_expr (E_op (Op_mult, [e1;e2])) }
| e1 = expr DIV e2 = expr
    { mk_expr (E_op (Op_div, [e1;e2])) }
| e1 = expr MOD e2 = expr
    { mk_expr (E_op (Op_mod, [e1;e2])) }
| e1 = expr LT e2 = expr
    { mk_expr (E_op (Op_lt, [e1;e2])) }
| e1 = expr LTEQ e2 = expr
    { mk_expr (E_op (Op_le, [e1;e2])) }
| e1 = expr GT e2 = expr
    { mk_expr (E_op (Op_gt, [e1;e2])) }
| e1 = expr GTEQ e2 = expr
    { mk_expr (E_op (Op_ge, [e1;e2])) }
| MINUS e1 = expr %prec UMINUS
    { mk_expr (E_op (Op_uminus, [e1])) }

(* Collections *)
| LCURL el = elist RCURL
    { mk_expr (E_list el) }

(* Conditionals *)
| e1 = expr QUESTION e2 = expr COLON e3 = expr
    { mk_expr (E_conditional (e1,e2,e3)) }

(* Accessors *)
| e1 = expr DOT id = IDENT
    { mk_expr (E_prop (e1, id)) }
| e1 = expr QUESTION DOT id = IDENT
    { mk_expr (E_prop_catch (e1, id)) }
| id = IDENT LPAREN el = elist RPAREN
    { mk_expr (E_call (None, id, el)) }
| e1 = expr DOT id = IDENT LPAREN el = elist RPAREN
    { mk_expr (E_call (Some e1, id, el)) }
| e1 = expr QUESTION DOT id = IDENT LPAREN el = elist RPAREN
    { mk_expr (E_call_catch (Some e1, id, el)) }
| NEW id = IDENT LPAREN el = elist RPAREN
    { mk_expr (E_new (id, el)) }
| e1 = expr LBRACKET e2 = expr RBRACKET
    { mk_expr (E_get_array (e1, e2)) }

elist:
| (* Empty *)
  { [] }
| e1 = expr
  { e1 :: [] }
| e1 = expr COMMA el = elist
  { e1 :: el }
    
body_main:
| b = body s = EOF
    { let eout = mk_expr (E_op (Op_concat, [b;mk_expr (E_lit (L_string s))]))
      in spel_cleanup eout }

body:
| 
    { mk_expr (E_lit (L_string "")) }
| bid = BODYVAR b = body
    { let eout = let (s,id) = bid in mk_expr (E_op (Op_concat, [mk_expr (E_lit (L_string s)); mk_expr (E_op (Op_concat, [mk_expr (E_op (Op_toString, [mk_expr (E_variable id)]));b]))]))
      in spel_cleanup eout }
| s = OPENEXPR e = expr CLOSEEXPR b = body
    { let eout = mk_expr (E_op (Op_concat, [mk_expr (E_lit (L_string s)); mk_expr (E_op (Op_concat, [mk_expr (E_op (Op_toString, [e]));b]))]))
      in spel_cleanup eout }
