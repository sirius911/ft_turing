(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   machine.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 11:39:01 by clorin            #+#    #+#             *)
(*   Updated: 2023/10/10 16:28:00 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Types
open Colors
open Tape
open Utils

type machine= {
  verbose : bool;
  name : string;
  alphabet : char list;
  blank : char;
  states : string list;
  initial : string;
  finals : string list;
  transitions : transitions;
  valid : bool;
  tape : Tape.t option;
  state : string;
}

let create_empty_machine () : machine = 
  {
    verbose = true;
    name = "empty";
    alphabet = [];
    blank = ' ';
    states = [];
    initial = " ";
    finals = [];
    transitions = Hashtbl.create 10;
    valid = false;
    tape = None;
    state = " ";
  }

let rec continue_prompt () : bool =
  Printf.printf "Do you want to execute (Y/N) ? ";
  flush stdout;
  let user_input = input_line stdin in
  match String.uppercase_ascii user_input with
  | "Y" -> true
  | "N" -> false
  | _ ->
    continue_prompt ()

let validation (a:char list) (b:char) (s:string list) (i:string) (f:string list) t = 
  if List.mem b a = false then
    failwith ("Blank caractere '"^(String.make 1 b)^"' must be part of Alphabet list.");
  if List.mem i s = false then
    failwith "State initial must be part of State list.";
  if not (List.for_all (fun final -> List.mem final s) f) then
    failwith "Finals states are not a subset of States list.";
  let found_halt_state = ref false in
  let t_list = Hashtbl.fold (fun _ transitions acc -> transitions @ acc) t [] in

  List.iter (fun trans ->
    if not (List.mem trans.read a) then
      failwith ("Read character '" ^ (String.make 1 trans.read) ^ "' not in alphabet.");
    if not (List.mem trans.to_state s) then
      failwith ("'" ^ trans.to_state ^ "' not in State list.");
    if not (List.mem trans.write a) then
      failwith ("Write character '" ^ (String.make 1 trans.write) ^ "' not in alphabet.");
    found_halt_state := !found_halt_state || List.mem trans.to_state f ;
  ) t_list;
  if !found_halt_state = false then
    (
    Printf.printf "%sWarning%s The list of transitions doesn't seem to have any stop states.\n" yellow reset;
    continue_prompt()
    )
  else
    true
  
let create (file: string) (_verbose : bool) :machine option =
  if file = "" then failwith "empty input";
  verboser ("Loading "^yellow^file^reset^" ... ") _verbose;
  try
    let json = Yojson.Basic.from_file file in
    let (n,a,b,s,i,f,t) = Parsing.parser json in
    match (validation (a) (b) (s) (i) (f) (t)) with
    | true -> verboser (" "^green^"Ok"^reset) _verbose;
      Some{
          verbose = _verbose;
          name = n;
          alphabet = a;
          blank = b;
          states = s;
          initial = i;
          finals = f;
          transitions = t;
          valid = true;
          tape = None;
          state = i;
        }
    | false -> None
  with
  | Yojson.Json_error msg -> Printf.printf "Error parsing JSON: %s\n" msg; None
  | ex -> Printf.printf "%sKO\nError: %s%s\n" red (Printexc.to_string ex) reset; None

let is_valid (m : machine) : bool =
  m.valid

let find_transition (trans : transitions) (state_name : string) : transition list =
  Hashtbl.find trans state_name
  
let print_transitions_for_state (m: machine) (state_name : string) : unit =
  Printf.printf "Transitions for state %s%s%s:\n" blue state_name reset;
  
  let _trans =
    try
      find_transition m.transitions state_name
    with
    | Not_found ->
      Printf.printf "State %s%s%s not found in transitions\n" yellow state_name reset;
      []
  in

  List.iter (fun trans ->
    let a = match trans.action with LEFT -> "LEFT" | RIGHT -> "RIGHT" in
    Printf.printf "\t%sRead:%s %c, %sTo State:%s %s, %sWrite%s: %c, %sAction:%s %s\n"
      yellow reset trans.read yellow reset trans.to_state yellow reset trans.write yellow reset a
  ) _trans

    
let print (m : machine) : unit = 
  if is_valid m then
    begin
      print_endline "**********************************************************";
      Printf.printf "*           %s                 \n" m.name;
      print_endline "**********************************************************";
      print_list_char m.alphabet "Alphabet";
      Printf.printf "Blank : '%c'\n" m.blank;
      print_list_string m.states "States";
      Printf.printf "Initial : %s\n" m.initial;
      print_list_string m.finals "Finals";
      List.iter (fun state_name ->
        print_transitions_for_state m state_name
      ) m.states;
      print_endline "**********************************************************";
    end
  else
    Printf.printf "Machine ... %sNot Valid%s\n" red reset

let have_tape (m : machine) : bool = 
    (m.tape <> None)

let add_tape (m : machine) (str : string) : machine =
  match str with
  | "" -> failwith "empty input"
  | _ when not (is_valid m) -> failwith "No machine valide !"
  | _ when String.contains str m.blank ->
    failwith ("The blank character '" ^ (String.make 1 m.blank) ^ "' must not be present in the input.")
  | _ when not (is_string_in_alphabet str m.alphabet) ->
    failwith "an input character is not present in Alphabet."
  | _ ->
    let new_tape = Tape.create str m.blank in
    {
      m with tape = Some new_tape;
    }

let get_state (m : machine) : string = 
  m.state

let get_name (m : machine) : string = 
  m.name

let read_head_tape (m : machine) : char = 
  match m.tape with
  | Some tap -> Tape.read_head tap
  | None -> failwith "No tape"

let get_transition (m : machine) : (char * direction * string) =
  let trans_state = find_transition (m.transitions) (m.state) in
  let read_ = read_head_tape m in
  let is_equal (transition : transition) (char_to_match : char) : bool =
    transition.read = char_to_match
  in
  match List.find_opt (fun trans -> is_equal trans read_) trans_state with
  | Some tt -> (tt.write, tt.action, tt.to_state)
  | None -> failwith ("'" ^ (String.make 1 read_) ^ "' Not Found in " ^ m.state)
  

let print_transition_info (m : machine) : string = 
  let read_ = read_head_tape m  in
  let (w, a, s) = get_transition m in
  "("^m.state^", "^(String.make 1 read_)^") -> ("^s^", "^(String.make 1 w)^", "^(direction_to_string a)^")\n"

let move_left (m : machine) : machine =
  match m.tape with
  | None -> failwith "No tape!"
  | Some tap -> { m with tape = Some (Tape.move_left tap) }

let move_right (m : machine) : machine= 
  match m.tape with
  | None -> failwith "No tape!";
  | Some tap -> { m with tape = Some (Tape.move_right tap) }

let tape_to_string (m : machine) : string = 
  match m.tape with
  | None -> "No tape!";
  | Some tap -> yellow^"["^reset^(pad_string_to_length (Tape.to_string tap) 30 m.blank)^yellow^"]"^reset

let reload (m : machine) : machine =
  match m.tape with
  | None -> failwith "No tape!"
  | Some tap -> { m with tape = Some (Tape.reload tap); state = m.initial }

let is_stopped (m: machine) : bool =
  List.mem m.state m.finals

let write (m : machine) (c : char) : machine =
  match m.tape with
  | None -> m
  | Some tap -> { m with tape = Some (Tape.write_head tap c) }

let set_state (m : machine) (new_state : string) : machine = 
  {m with state = new_state}

let step (m : machine) : machine =
  try  
    verboser ((tape_to_string m)^print_transition_info m) m.verbose;
    let (w, a, ns) = get_transition m in
    let new_machine = set_state m ns in
    match a with
      | LEFT -> move_left (write new_machine w)
      | RIGHT -> move_right (write new_machine w)
  with
  | Not_found -> failwith ("[" ^ m.state ^ "] Not Found !")

let run (m: machine) : int =
  let rec loop (count: int) (machine: machine) =
    if not (is_valid machine) then
      (
        verboser "No machine is valid\n" m.verbose;
        count
      )
    else if is_stopped machine then
      (
        verboser ((Utils.pad_string_to_length (tape_to_string machine) 30 m.blank)^"\n"^string_of_int count^" operation(s)\n") m.verbose;
        count
      )
    else
      loop (count + 1) (step machine)
  in
  loop 0 m

    
