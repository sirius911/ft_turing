module type Tape = 
sig
  type  t

  val tape_head:int
  val blank : char
  val input : string

  val init_tape : string -> char -> t
  val reload : unit -> unit
  val move_left : unit -> char
  val move_right : unit ->  char
end