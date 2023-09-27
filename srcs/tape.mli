module Tape :
sig
  type  t

  val create : string -> char -> t
  val init : t -> string -> t
  val reload : t -> t
  val move_left : t -> t
  val move_right : t ->  t
  val read_head : t -> char
  val write_head : t -> char -> t
  val print : t -> unit
  val to_string : t -> string
end