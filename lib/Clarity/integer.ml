(* This is free and unencumbered software released into the public domain. *)

module Integer = struct
  type t = Big_int.big_int

  let equal = Big_int.eq_big_int
  let compare = Big_int.compare_big_int

  let of_int = Big_int.big_int_of_int
  let of_int32 = Big_int.big_int_of_int32
  let of_int64 = Big_int.big_int_of_int64
  let of_string = Big_int.big_int_of_string

  let to_int = Big_int.int_of_big_int
  let to_int32 = Big_int.int32_of_big_int
  let to_int64 = Big_int.int64_of_big_int
  let to_float = Big_int.float_of_big_int
  let to_string = Big_int.string_of_big_int
end
