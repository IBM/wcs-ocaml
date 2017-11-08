type ('a, 'b) result =
  | Ok of 'a
  | Error of 'b

type ('a, 'b) deriving_result = ('a, 'b) result

type 'a deriving_error_or = ('a, string) deriving_result
