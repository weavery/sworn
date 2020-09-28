(* This is free and unencumbered software released into the public domain. *)

module Sexp = struct
  type t =
    | Atom of literal
    | List of t list

  let rec equal a b = match (a, b) with
    | Atom a, Atom b -> equal_literal a b
    | List [], List [] -> true
    | List (x :: xs), List (y :: ys) ->
      (equal x y) && (equal (List xs) (List ys))
    | _, _ -> false

  let rec print ppf = function
    | Atom literal -> print_literal ppf literal
    | List exprs ->
      Format.fprintf ppf "(%a)"
        (Format.pp_print_list ~pp_sep:Format.pp_print_space print) exprs
end
