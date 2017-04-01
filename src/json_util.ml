
let read_json_file reader f =
  begin try
    let lexstate = Yojson.init_lexer ~fname:f () in
    let ch = open_in f in
    let lexbuf = Lexing.from_channel ch in
    let json = reader lexstate lexbuf in
    close_in ch;
    json
  with
  | Yojson.Json_error err ->
      Log.error "Json_util" None
        ("Unable to parse file "^f^": "^err)
  | exn ->
      Log.error "Json_util" None
        ("Unable to read file "^f^": "^(Printexc.to_string exn))
  end
