(* This is free and unencumbered software released into the public domain. *)

val verbose : bool Cmdliner.Term.t
val files : string list Cmdliner.Term.t
val output : string option Cmdliner.Term.t
val target : Target.t Cmdliner.Term.t
val optimize : int Cmdliner.Term.t
