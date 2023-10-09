
open Types

type machine

val create_empty_machine : unit -> machine
val create : string -> bool -> machine option
val add_tape : machine -> string -> machine
val print : machine -> unit
val have_tape : machine -> bool
val tape_to_string : machine -> string
val reload : machine -> machine
val is_valid : machine -> bool
val read_head_tape : machine -> char
val print_transitions_for_state : machine -> string -> unit
val get_transition : machine -> (char * direction * string)
val print_transition_info : machine -> string
val get_state : machine -> string
val get_name : machine-> string
val move_left : machine -> machine
val move_right : machine -> machine
val is_stopped : machine -> bool
val write : machine -> char -> machine
val step : machine -> machine
val run : machine -> int 