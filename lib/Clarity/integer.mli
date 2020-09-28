(* This is free and unencumbered software released into the public domain. *)

module Integer : sig
  type t = Big_int.big_int

  val equal : t -> t -> bool
  val compare : t -> t -> int

  val of_int : int -> t
  val of_int32 : int32 -> t
  val of_int64 : int64 -> t
  val of_string : string -> t

  val to_int : t -> int
  val to_int32 : t -> int32
  val to_int64 : t -> int64
  val to_float : t -> float
  val to_string : t -> string
end
