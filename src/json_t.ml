type safe = Yojson.Safe.json
type basic = Yojson.Basic.json
type json = basic

let write_json = Yojson.Basic.write_json
let read_json = Yojson.Basic.read_json
