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

open Wcs_t
module Mk = Wcs

let intent_help =
  Mk.intent "help"
    ~description:"The user needs help knowing what to do"
    ~examples:[ "help";
                "I am confused";
                "What can I do";
                "What are my choices";
                "options";
                "alternatives";
                "choices";
                "usage";
                "guide";
                "directions"; ]
    ()

let is_number =
  Mk.dialog_node "Is number"
    ~conditions: "@sys-number"
    ~text: "You have selected the number @sys-number."
    ~context: (Json.set_skip_user_input `Null true)
    ()

let win =
  Mk.dialog_node "Win"
    ~parent: is_number
    ~conditions: "@sys-number == 42"
    ~text: "You win!"
    ~context: (Json.set_return `Null (`Bool true))
    ()

let lost =
  Mk.dialog_node "Lost"
    ~previous_sibling: win
    ~conditions: "anything_else"
    ~text: "Sorry, do you want to try again?"
    ()


let mk_prompt prompt_txt help_txt =
  let prompt =
    Mk.dialog_node "Prompt"
      ~conditions: "conversation_start"
      ~text: prompt_txt
      ()
  in
  let help =
    Mk.dialog_node "Help"
      ~conditions: "#help"
      ~text: help_txt
      ~next_step: (prompt, Goto_body)
      ()
  in
  let default =
    Mk.dialog_node "Default"
      ~text: "I don't understand what you say."
      ~next_step: (help, Goto_body)
      ()
  in
  [ prompt; help; default; ]

let example1 =
  Mk.workspace "Example 1"
    ~intents: [ intent_help ]
    ~entities: [ Mk.sys_number ]
    ~dialog_nodes: (is_number
                    :: win
                    :: lost
                    :: (mk_prompt
                          "Enter a number."
                          "It is a game where you have to guest a number."))
    ()

let () =
  print_endline
    (Wcs_json.pretty_workspace example1)
