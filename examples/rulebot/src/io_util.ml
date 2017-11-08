open Cnl_print
open Dialog_interface_t
open Wcs_t

let slack_io = ref false
let set_slack_io () =
  slack_io := true

let slack_log = ref None
let set_slack_log f =
  slack_log := Some (open_out f)
let log msg =
  begin match !slack_log with
  | None -> ()
  | Some oc ->
      output_string oc msg; flush oc
  end
let close_slack_log () =
  begin match !slack_log with
  | None -> ()
  | Some oc -> close_out oc;
  end

let pretty_json_string s =
  Yojson.Basic.pretty_to_string (Yojson.Basic.from_string s)

let slack_response msg =
  let resp = Yojson.Basic.to_string (`Assoc [("text", `String msg);("userinput", `Bool false);("status",`String "active")]) in
  begin
    log (resp ^ "\n");
    print_endline resp
  end

let slack_user_input () =
  let resp = Yojson.Basic.to_string (`Assoc [("text", `String "");("userinput", `Bool true);("status",`String "active")]) in
  begin
    log (resp ^ "\n");
    print_endline resp
  end

let slack_done () =
  let resp = Yojson.Basic.to_string (`Assoc [("text", `String "");("userinput", `Bool false);("status",`String "done")]) in
  begin
    log (resp ^ "\n");
    print_endline resp
  end

let print_rule_line () =
  if not(!slack_io)
  then
    print_endline "--------"

let print_berl_error quoted_string =
  let error_msg = "Quoted expression `"^quoted_string^"` is not valid BERL" in
  if not(!slack_io)
  then
    print_endline ("[WARNING] " ^ error_msg)
  else
    slack_response error_msg

let print_rule r =
  if not(!slack_io)
  then
    print_endline (cnl_print_rule_top r)
  else
    let msg = Printf.sprintf "```\n%s\n```\n" (cnl_print_rule_top r) in
    slack_response msg

let print_workspace ws_ids =
  if not(!slack_io)
  then
    begin
      print_endline "-------------------------";
      print_endline "Workspaces configuration:";
      print_endline (pretty_json_string ws_ids);
      print_endline "-------------------------"
    end

let print_instr nb =
  if not(!slack_io)
  then
    print_endline ((string_of_int nb) ^ ">")

let print_done () =
  if not(!slack_io)
  then
    print_endline ">DONE"
  else
    slack_done ()
    

let print_C msg =
  if not(!slack_io)
  then
    print_endline ("C: "^msg)
  else
    slack_response msg

let print_output_stdout rule_opt msg =
  begin match rule_opt with
  | Some rule ->
      print_rule_line ();
      print_rule rule;
      print_rule_line ()
  | None -> ()
  end;
  print_C msg

(* input *)

let get_input_stdin () =
  if not(!slack_io)
  then
    begin
      print_string "H: "; flush stdout;
      input_line stdin
    end
  else
    begin
      slack_user_input ();
      let text = input_line stdin in
      log ("H:" ^ text ^ "\n");
      text
    end

