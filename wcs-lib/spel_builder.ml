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


(** Spel data structure constructors *)

open Spel_t
open Wcs_t

(** {6 from OCaml types} *)

let of_string s =
  Spel_parse.expression_from_string s

let of_text s =
  Spel_parse.expression_from_text_string s

let of_json j =
  Spel_parse.json_expression_from_json j

let entity entity_def ?value () =
  begin match value with
  | None ->
      Spel_util.mk_expr (E_entity (entity_def.e_def_entity, None))
  | Some value_def ->
      let value = value_def.e_val_value in
      if List.mem value (List.map (fun ev -> ev.e_val_value) entity_def.e_def_values)
      then
        Spel_util.mk_expr (E_entity (entity_def.e_def_entity, Some value))
      else
        Log.error "Spel builder" None ("Undefined entity: " ^  value)
  end

let intent intent_def =
  Spel_util.mk_expr (E_intent intent_def.i_def_intent)

let bool b =
  Spel_util.mk_expr (E_lit (L_boolean b))

(** {6 other constructors} *)

let conversation_start =
  Spel_util.mk_expr E_conversation_start

let anything_else =
  Spel_util.mk_expr E_anything_else

(** {6 Spel checker *)

let spel_check s =
  Spel_print.to_string
    (of_string s)

(** {6 desugaring} *)

let rec fold_expr f e =
  let desc = 
    begin match e.expr_desc with
    | E_lit l -> E_lit l
    | E_prop (e, s) -> E_prop (fold_expr f e, s)
    | E_prop_catch (e, s) ->
        E_prop_catch (fold_expr f e, s)
    | E_get_array (e1, e2) ->
        E_get_array (fold_expr f e1,
                     fold_expr f e2)
    | E_get_dictionary (e1, e2) ->
        E_get_dictionary (fold_expr f e1,
                          fold_expr f e2)
    | E_list el ->
        E_list (List.map (fold_expr f) el)
    | E_new_array (t, ilo, elo) ->
        begin match elo with
        | None ->
            E_new_array (t, ilo,
                         None)
        | Some el ->
            E_new_array (t, ilo,
                         Some (List.map (fold_expr f) el))
        end
    | E_new (t, el) ->
        E_new (t, List.map (fold_expr f) el)
    | E_call (eo, s, el) ->
        begin match eo with
        | None ->
            E_call (None, s,
                    List.map (fold_expr f) el)
        | Some e ->
            E_call (Some (fold_expr f e), s,
                    List.map (fold_expr f) el)
        end
    | E_call_catch (eo, s, el) ->
        begin match eo with
        | None ->
            E_call_catch (None, s,
                          List.map (fold_expr f) el)
        | Some e ->
            E_call_catch (Some (fold_expr f e), s,
                          List.map (fold_expr f) el)
        end
    | E_op (op, el) ->
        E_op (op, List.map (fold_expr f) el)
    | E_conditional (e1, e2, e3) ->
        E_conditional (fold_expr f e1,
                       fold_expr f e2,
                       fold_expr f e3)
    | E_ident s -> E_ident s
    (* WCS extensions *)
    | E_anything_else -> E_anything_else
    | E_context -> E_context
    | E_conversation_start -> E_conversation_start
    | E_entities -> E_entities
    | E_input -> E_input
    | E_intents -> E_intents
    | E_output -> E_output
    | E_variable s -> E_variable s
    | E_intent s -> E_intent s
    | E_entity (s1, s2) -> E_entity (s1, s2)
    (* Fallback *)
    | E_error s -> E_error s
    end
  in
  let desc = f desc in
  let loc = e.expr_loc in
  let text = e.expr_text in
  Spel_util.mk_expr_full desc loc text

let refresh_expr_text e =
  begin match e.expr_text with
  | None -> ()
  | Some t ->
      e.expr_text <- Some (Spel_print.to_string e)
  end

let desugar_desc e =
  begin match e with
  | E_variable (s,None) ->
      E_get_dictionary (Spel_util.mk_expr E_context,
                        Spel_util.mk_expr (E_lit (L_string s)))
  | _ -> e
  end

let desugar e =
  fold_expr desugar_desc e

let resugar_desc e =
  begin match e with
  | E_get_dictionary ({ expr_desc = E_context },
                      { expr_desc = E_lit (L_string s) }) ->
      E_variable (s,None)
  | _ -> e
  end

let resugar e =
  fold_expr resugar_desc e

