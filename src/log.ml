exception Error of string * string

let column s =
  if s = "" then ""
  else ": "^s

let warning (module_name: string) (msg: string) : unit =
  Format.eprintf "[Warning%s] %s@." (column module_name) msg

let error_recovery = ref true

let print_error module_name msg =
  Format.eprintf "[Error%s] %s@." (column module_name) msg

let error (module_name: string) (default: 'a option) (msg: string) : 'a =
  begin match !error_recovery, default with
  | true, Some v ->
      print_error module_name msg;
      v
  | false, Some _
  | _, None -> raise (Error (module_name, msg))
  end

let debug_message = ref true

let debug (module_name: string) (msg: string) : unit =
  Format.eprintf "[Debug%s] %s@." (column module_name) msg
