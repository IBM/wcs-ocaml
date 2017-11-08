(** {6. Locations} *)

type location = Lexing.position * Lexing.position

(** BMD AST *)
      
type bmd_schema = {
    schema_desc : bmd_schema_desc;
    schema_loc : location;
  }
and bmd_schema_desc = bmd_concept list

and bmd_concept = {
    concept_desc : bmd_concept_desc;
    concept_loc : location;
  }
and bmd_concept_desc = bmd_concept_name * bmd_concept_name option * bmd_type (* First name is current concept ; Second name is the concept it derives from *)

and bmd_type = {
    type_desc : bmd_type_desc;
    type_loc : location;
  }

and bmd_type_desc =
  | BT_string
  | BT_int
  | BT_real
  | BT_boolean
  | BT_date
  | BT_duration
  | BT_rec of (bmd_field_name * bmd_type) list
  | BT_enum of string list
  | BT_ref of bmd_concept_name

and bmd_concept_name = string
and bmd_field_name = string

(** BMD Construction *)

type bmd_constr =
  | BC_concept of (bmd_concept_name * bmd_concept_name option)
  | BC_enum of (bmd_concept_name * string list)
  | BC_field of (bmd_concept_name * bmd_field_name * bmd_type)

type bmd_spec = bmd_constr list

