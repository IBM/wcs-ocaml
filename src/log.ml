exception Error

let column s =
  if s = "" then ""
  else ": "^s

let error_recovery = ref true

let error (module_name: string) (default: 'a option) (msg: string) : 'a =
  Format.eprintf "[Error%s] %s@." (column module_name) msg;
  begin match !error_recovery, default with
  | true, Some v -> v
  | false, Some _
  | _, None -> raise Error
  end

let warning (module_name: string) (msg: string) : unit =
  Format.eprintf "[Warning%s] %s@." (column module_name) msg

let debug_message = ref true

let debug (module_name: string) (msg: string) : unit =
  Format.eprintf "[Debug%s] %s@." (column module_name) msg
