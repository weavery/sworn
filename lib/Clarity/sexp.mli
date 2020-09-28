(* This is free and unencumbered software released into the public domain. *)

module Sexp : sig
  type t =
    | Sym of string
    | Lit of literal
    | List of t list
  val equal : t -> t -> bool
  val print : Format.formatter -> t -> unit
end
