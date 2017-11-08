open Cnl_t
open Cnl_util
open Cnl_print
open Cnl_samples
open Cnl_scripts

open Bmd_t
open Bmd_util
open Bmd_samples
open Bmd_to_wcs_entities
open Bmd_spec_to_bmd

open Wcs_t
open Dialog_interface_t

(* Util *)

let oiter f o =
  begin match o with
  | None -> ()
  | Some x -> f x
  end

let read_json_file filetype reader f =
  begin try
    let lexstate = Yojson.init_lexer ~fname:f () in
    let ch = open_in f in
    let lexbuf = Lexing.from_channel ch in
    let json = reader lexstate lexbuf in
    close_in ch;
    json
  with
  | Yojson.Json_error err ->
      raise (Failure ("Unable to parse "^ filetype ^ " file "^f^": "^err))
  | exn ->
      raise(Failure ("Unable to read " ^ filetype ^ " file "^f^": "^(Printexc.to_string exn)))
  end

let load_io io_file =
  read_json_file "io" Io_j.read_io io_file

let convert_json_rule j =
  begin match Cnl_t.cnl_rule_of_yojson j with
  | Deriving_intf.Ok x -> x
  | (Deriving_intf.Error _) -> raise (Failure "Couldn't parse json file")
  end

let convert_json_instr j =
  begin match Cnl_instr_t.cnl_instr_of_yojson j with
  | Deriving_intf.Ok x -> x
  | (Deriving_intf.Error _) -> raise (Failure "Couldn't parse json file")
  end

let parse_rule f =
  let rule_j = Yojson.Safe.from_file f in
  convert_json_rule rule_j

let get_workspace_id ?(update=false) ws_name wcs_cred ws_config get_id_fname ws =
  let ws_id, ws_fname =
    begin match ws_config with
    | Some config -> get_id_fname config
    | None -> (None, None)
    end
  in
  begin match ws_id with
  | Some id ->
      begin match update, ws with
      | true, Some w ->
          Wcs_api.update_workspace wcs_cred id w;
          id
      | _, _ -> id
      end
  | None ->
      let workspace =
        begin match ws_fname, ws with
        | Some fname, _ -> read_json_file "workspace" Wcs_j.read_workspace fname
        | None, Some w -> w
        | None, None -> raise (Failure ("Workspace "^ws_name^" required"))
        end
      in
      let rsp = Wcs_api.create_workspace wcs_cred workspace in
      begin match rsp.crea_rsp_workspace_id with
      | Some id -> id
      | None -> raise (Failure ("Unable to create workspace "^ws_name))
      end
  end

let string_of_ws_ids ws_ids =
  let open Dialog_ctrl in
  let config =
    { ws_select_example = None;
      ws_select_example_id = None;
      ws_select_expr = None;
      ws_select_expr_id = None;
      ws_dispatch = None;
      ws_dispatch_id = Some ws_ids.Dialog_util.ws_dispatch_id;
      ws_when = None;
      ws_when_id = Some ws_ids.Dialog_util.ws_when_id;
      ws_cond = None;
      ws_cond_id = Some ws_ids.Dialog_util.ws_cond_id;
      ws_cond_continue = None;
      ws_cond_continue_id = Some ws_ids.Dialog_util.ws_cond_continue_id;
      ws_then = None;
      ws_then_id = Some ws_ids.Dialog_util.ws_then_id;
      ws_expr = None;
      ws_expr_id = Some ws_ids.Dialog_util.ws_expr_id;
      ws_actn = None;
      ws_actn_id = Some ws_ids.Dialog_util.ws_actn_id;
      ws_accept = None;
      ws_accept_id = Some ws_ids.Dialog_util.ws_accept_id; }
  in
  Dialog_interface_j.string_of_config config

let load_ws_ids wcs_cred workspaces_config ws_update bmd =
  let ws_dispatch_id =
    get_workspace_id ~update:ws_update "dispatch"
      wcs_cred workspaces_config
      (fun config -> (config.ws_dispatch_id, config.ws_dispatch))
      (Some (Ws_dispatch.ws_dispatch (fst bmd)))
  in
  let ws_when_id =
    get_workspace_id ~update:ws_update "when"
      wcs_cred workspaces_config
      (fun config -> (config.ws_when_id, config.ws_when))
      (Some (Ws_when.ws_when (snd bmd)))
  in
  let ws_cond_id =
    get_workspace_id ~update:ws_update "cond"
      wcs_cred workspaces_config
      (fun config -> (config.ws_cond_id, config.ws_cond))
      (Some Ws_cond.ws_cond)
  in
  let ws_cond_continue_id =
    get_workspace_id ~update:ws_update "cond-continue"
      wcs_cred workspaces_config
      (fun config -> (config.ws_cond_continue_id, config.ws_cond_continue_id))
      (Some Ws_cond_continue.ws_cond_continue)
  in
  let ws_then_id =
    get_workspace_id ~update:ws_update "then"
      wcs_cred workspaces_config
      (fun config -> (config.ws_then_id, config.ws_then))
      (Some Ws_then.ws_then)
  in
  let ws_expr_id =
    get_workspace_id ~update:ws_update "expr"
      wcs_cred workspaces_config
      (fun config -> (config.ws_expr_id, config.ws_expr))
      (Some (Ws_expr.ws_expr (snd bmd)))
  in
  let ws_actn_id =
    get_workspace_id ~update:ws_update "actn"
      wcs_cred workspaces_config
      (fun config -> (config.ws_actn_id, config.ws_actn))
      (Some (Ws_actn.ws_actn (snd bmd)))
  in
  let ws_accept_id =
    get_workspace_id ~update:ws_update "accept"
      wcs_cred workspaces_config
      (fun config -> (config.ws_accept_id, config.ws_accept))
      (Some Ws_accept.ws_accept)
  in
  let ws_ids =
    { Dialog_util.ws_dispatch_id = ws_dispatch_id;
      ws_when_id = ws_when_id;
      ws_cond_id = ws_cond_id;
      ws_cond_continue_id = ws_cond_continue_id;
      ws_then_id = ws_then_id;
      ws_expr_id = ws_expr_id;
      ws_actn_id = ws_actn_id;
      ws_accept_id = ws_accept_id; }
  in
  Io_util.print_workspace (string_of_ws_ids ws_ids);
  ws_ids

(* Command line *)
type mode =
  | M_nothing
  | M_samples
  | M_script_samples
  | M_parse of string
  | M_script of string
  | M_wcs of string
  | M_ws_gen
  | M_ws_delete

let rulebot_mode : mode ref = ref M_nothing
let set_samples_mode () = rulebot_mode := M_samples
let set_script_samples_mode () = rulebot_mode := M_script_samples
let set_parse_mode f = rulebot_mode := M_parse f
let set_script_mode f = rulebot_mode := M_script f
let set_ws_delete_mode f = rulebot_mode := M_ws_delete
let set_ws_gen_mode f = rulebot_mode := M_ws_gen
let set_wcs_mode main = rulebot_mode := M_wcs main

let bom_io = ref None
let set_bom_io file =
  bom_io := Some file

let bmd = ref None
let set_bmd file =
  bmd := Some file

let wcs_credential : Wcs_t.credential option ref = ref None
let set_wcs_credential f =
  wcs_credential := Some (read_json_file "credential" Wcs_j.read_credential f)


let workspaces_config = ref None
let set_workspaces_config f =
  let config =
    read_json_file "workspaces_config" Dialog_interface_j.read_config f
  in
  workspaces_config := Some config

let ws_update = ref false
let set_ws_update () =
  ws_update := true


let is_slack = ref false
let set_is_slack () =
  is_slack := true

let slackbot = ref "cat"
let set_slackbot cmd =
  slackbot := cmd


let rule_init : cnl_rule ref = ref (Cnl_samples.rule_init ())
let set_init_rule f = rule_init := parse_rule f
let focus_init : int ref = ref 0
let set_init_focus i = focus_init := i

let anon_args f = raise (Failure "rulebot expects no parameters")

let args =
  Arg.align
    [ ("-wcs-cred", Arg.String set_wcs_credential,
       "file The file containing the Watson Conversation Service credentials");
      ("-wcs", Arg.String set_wcs_mode,
       "main Select the main program (requires -wcs-cred)");
      ("-bom-io", Arg.String set_bom_io,
       "io.json replace workspace entities using I/O file");
      ("-bmd", Arg.String set_bmd,
       ".bmd replace workspace entities using BMD file");
      ("-ws-config", Arg.String set_workspaces_config,
       "config.json The file containing id or file name of the workspaces");
      ("-ws-update", Arg.Unit set_ws_update,
       " Updates workspaces given by -workspaces-config in Watson Conversation (the others are deployed)");
      ("-ws-delete", Arg.Unit set_ws_delete_mode,
       " Delete workspaces given by -workspaces-config in Watson Conversation");
      ("-ws-gen", Arg.Unit set_ws_gen_mode,
       " Generate workspaces in JSON");
      ("-slack", Arg.Unit set_is_slack,
       " Launch as a Slackbot");
      ("-slack-io", Arg.Unit Io_util.set_slack_io,
       " I/O for Slackbot");
      ("-slack-log", Arg.String Io_util.set_slack_log,
       " Log I/O for Slackbot");
      ("-slackbot", Arg.String set_slackbot,
       "cmd Set the slackbot-stdio command");
      ("-samples", Arg.Unit set_samples_mode,
       " Export sample rules to JSON");
      ("-script-samples", Arg.Unit set_script_samples_mode,
       " Export sample scripts to JSON");
      ("-parse", Arg.String set_parse_mode,
       "rule.json JSON CNL rule parse and emit");
      ("-script", Arg.String set_script_mode,
       "script.json JSON CNL script parse and emit");
      ("-rule", Arg.String set_init_rule,
       "r Initial rule");
      ("-focus", Arg.Int set_init_focus,
       "n Initial focus");
   ]

let usage = "rulebot [options]"

(* Parsing and emit mode *)

let script_one_line instr_nb rule_before ic =
  let one_line = input_line ic in
  let instr_j = Yojson.Safe.from_string one_line in
  let instr = convert_json_instr instr_j in
  let rule_after = Cnl_engine.cnl_instr_apply instr rule_before in
  begin
    incr instr_nb;
    Io_util.print_instr !instr_nb;
    Io_util.print_rule rule_after;
    rule_after
  end

let parse_script f =
  let ic = open_in f in
  let instr_nb = ref 0 in
  let rule_init = !rule_init in
  let rec loop rule =
    let next_rule = script_one_line instr_nb rule ic in
    loop next_rule
  in
  begin
    Io_util.print_instr !instr_nb;
    Io_util.print_rule rule_init;
    try loop rule_init with
    | _ ->
	begin
	  close_in ic;
	  Io_util.print_done ()
	end
  end

(* Samples mode *)
(* File print *)

let make_file fout scomp =
  let oc = open_out fout in
  begin
    output_string oc scomp;
    close_out oc
  end

let proc_sample sample =
  let (rulename,rule) = sample in
  let rule_s = Yojson.Safe.to_string (Cnl_t.cnl_rule_to_yojson rule)
  in
  make_file (rulename ^ ".json") rule_s

let proc_script_sample script_sample =
  let (scriptname,script) = script_sample in
  let script_s =
    String.concat "\n"
      (List.map (fun x -> Yojson.Safe.to_string (Cnl_instr_t.cnl_instr_to_yojson x)) script)
  in
  make_file (scriptname ^ ".json") script_s

let samples () =
  List.iter proc_sample cnl_samples

let script_samples () =
  List.iter proc_script_sample cnl_script_samples

(* WCS mode *)

let wcs bmd main =
  begin match main, !wcs_credential with
  | "select_example", Some wcs_cred ->
      let ws_select_example_id =
        get_workspace_id ~update:!ws_update "select_example"
          wcs_cred !workspaces_config
          (fun config -> (config.ws_select_example_id, config.ws_select_example))
          (Some Ws_select_example.ws_select_example)
      in
      Dialog_ctrl.select_example wcs_cred ws_select_example_id
  | "select_expr", Some wcs_cred ->
      let ws_select_expr_id =
        get_workspace_id ~update:!ws_update "select_expr"
          wcs_cred !workspaces_config
          (fun config -> (config.ws_select_expr_id, config.ws_select_expr))
          (Some Ws_select_expr.ws_select_expr)
      in
      ignore (Dialog_ctrl.select_expr wcs_cred ws_select_expr_id `Null)
  | "rule", Some wcs_cred ->
      let ws_ids = load_ws_ids wcs_cred !workspaces_config !ws_update bmd in
      ignore (Dialog_ctrl.build_rule wcs_cred ws_ids)
  | "when", Some wcs_cred ->
      let id =
        get_workspace_id ~update:!ws_update "when"
          wcs_cred !workspaces_config
          (fun config -> (config.ws_when_id, config.ws_when))
          (Some (Ws_when.ws_when (snd bmd)))
      in
      ignore (Dialog_ctrl.build_when_step wcs_cred id !rule_init !focus_init)
  | "cond", Some wcs_cred ->
      let id =
        get_workspace_id ~update:!ws_update "cond"
          wcs_cred !workspaces_config
          (fun config -> (config.ws_cond_id, config.ws_cond))
          (Some Ws_cond.ws_cond)
      in
      ignore (Dialog_ctrl.build_cond_step wcs_cred id !rule_init !focus_init)
  | "actn", Some wcs_cred ->
      let id =
        get_workspace_id ~update:!ws_update "actn"
          wcs_cred !workspaces_config
          (fun config -> (config.ws_actn_id, config.ws_actn))
          (Some (Ws_actn.ws_actn (snd bmd)))
      in
      ignore (Dialog_ctrl.build_actn_step wcs_cred id !rule_init !focus_init)
  | _, Some _ ->
      Arg.usage args ("Unknown main "^main^"\n"^usage)
  | _, None ->
      Arg.usage args ("Watson Conversation credentials required\n"^usage)
  end


(* Workspaces generation *)
let workspaces_generation bmd =
  let output_ws ws =
    let ws_s =
      Io_util.pretty_json_string (Wcs_j.string_of_workspace ws)
    in
    begin match ws.ws_name with
    | Some name ->
        let fname = name^".json" in
        print_endline (fname^" generated");
        let ch = open_out fname in
        output_string ch ws_s;
        close_out ch
    | None ->
        print_endline ws_s
    end
  in
  output_ws Ws_accept.ws_accept;
  output_ws (Ws_actn.ws_actn (snd bmd));
  output_ws Ws_then.ws_then;
  output_ws (Ws_expr.ws_expr (snd bmd));
  output_ws (Ws_dispatch.ws_dispatch (fst bmd));
  output_ws Ws_cond.ws_cond;
  output_ws Ws_cond_continue.ws_cond_continue;
  output_ws (Ws_when.ws_when (snd bmd));
  ()

(* Workspace deletion *)

let workspaces_delete () =
  let wcs_cred =
    begin match !wcs_credential with
    | Some cred -> cred
    | None -> raise (Failure ("Watson Conversation credentials required"))
    end
  in
  let ws_conf =
    begin match !workspaces_config with
    | Some conf -> conf
    | None -> raise (Failure ("Workspaces configuration file required"))
    end
  in
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_select_example_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_select_expr_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_dispatch_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_when_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_cond_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_cond_continue_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_then_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_expr_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_actn_id;
  oiter (Wcs_api.delete_workspace wcs_cred) ws_conf.ws_accept_id;
  ()

(* Top *)
let main () =
  let bmd =
    begin match !bmd with
    | None ->
	begin match !bom_io with
	| None ->
	    ("[Sample BMD]", Bmd_samples.creditcard_schema)
	| Some io_file ->
	    let io_j = load_io io_file
	    in ("[BMD from IO]", Io_to_bmd.bmd_of_io io_j)
	end
	| Some file ->
	    (Parser_util.string_of_file file, Bmd_spec_to_bmd.bmd_schema_of_spec (Parser_util.parse_bmd_spec_from_file file))
    end
  in
  begin match !rulebot_mode with
  | M_nothing -> Arg.usage args usage
  | M_samples -> samples ()
  | M_script_samples -> script_samples ()
  | M_parse f -> Io_util.print_rule (parse_rule f)
  | M_script f -> parse_script f
  | M_wcs main -> wcs bmd main
  | M_ws_gen -> workspaces_generation bmd
  | M_ws_delete -> workspaces_delete ()
  end
