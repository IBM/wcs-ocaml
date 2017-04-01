type safe = Yojson.Safe.json
type basic = Yojson.Basic.json
type json = basic

type ('a, 'b) deriving_result = ('a, 'b) Ppx_deriving_yojson_runtime.Result.result

type 'a deriving_error_or = 'a Ppx_deriving_yojson_runtime.error_or


let write_json = Yojson.Basic.write_json
let read_json = Yojson.Basic.read_json
