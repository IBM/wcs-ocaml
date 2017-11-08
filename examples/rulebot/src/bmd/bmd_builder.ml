open Bmd_t

let mk_bmd_concept_with_loc desc loc = {
  concept_desc = desc;
  concept_loc = loc;
}

let mk_bmd_concept cname1 cname2 ctype =
  mk_bmd_concept_with_loc (cname1,cname2,ctype) (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())

let mk_bmd_type_with_loc desc loc = {
  type_desc = desc;
  type_loc = loc;
}
    
let mk_bmd_type desc =
  mk_bmd_type_with_loc desc (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())

let mk_bmd_string () = mk_bmd_type BT_string
let mk_bmd_int () = mk_bmd_type BT_int
let mk_bmd_real () = mk_bmd_type BT_real
let mk_bmd_boolean () = mk_bmd_type BT_boolean
let mk_bmd_date () = mk_bmd_type BT_date
let mk_bmd_duration () = mk_bmd_type BT_duration
let mk_bmd_rec fields = mk_bmd_type (BT_rec fields)
let mk_bmd_enum values = mk_bmd_type (BT_enum values)
let mk_bmd_ref cname = mk_bmd_type (BT_ref cname)


let mk_bmd_schema_with_loc desc loc = {
  schema_desc = desc;
  schema_loc = loc
}

let mk_bmd_schema desc =
  mk_bmd_schema_with_loc desc (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())
    
