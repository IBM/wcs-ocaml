open Bmd_t

val find_fields :
  bmd_concept_name ->
  bmd_constr list -> (bmd_field_name * bmd_type) list
val bmd_rec_of_fields :
  (bmd_field_name * bmd_type) list -> bmd_type
val bmd_concept_of_concept :
  bmd_constr list -> bmd_concept_name -> bmd_concept_name option -> bmd_concept
val bmd_concept_of_enum :
  bmd_concept_name -> string list -> bmd_concept
val bmd_concepts_of_spec : bmd_constr list -> bmd_concept list
val bmd_schema_of_spec : bmd_constr list -> bmd_schema
