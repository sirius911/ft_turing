(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   machine.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 11:39:01 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/26 17:25:34 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Types
open Colors
open Tape
open Yojson.Basic.Util
open Utils

type transition = {
  read: char;
  to_state: string;
  write: char;
  action: direction;
}

type transitions = (string, transition list) Hashtbl.t

module Tape = 
struct
  type t = {
    mutable tape_contents : char list;
    mutable tape_head : int;
    blank : char;
    input : string;
  }

  let create (initial_string : string) (blank : char) =
    {
      tape_contents = List.of_seq (String.to_seq initial_string);
      tape_head = 0;
      blank = blank;
      input = initial_string;
    }
  
  let init (tape : t) (initial_string : string) : t =
    tape.tape_contents <- List.of_seq (String.to_seq initial_string);
    tape

  let reload (tape : t) : t =
    tape.tape_head <- 0; 
    init tape tape.input
      
  let print (tape : t) : unit =
    List.iteri (fun i cell ->
      if i = tape.tape_head then Printf.printf "<%s%c%s>" "\x1b[31m" cell "\x1b[0m"
      else print_char cell) tape.tape_contents;
    print_newline ()

  let to_string (tape : t) : string = 
    let rec loop liste ret i = match liste with
      | [] -> ret
      | head::queue -> 
        if i = tape.tape_head then
          ret ^red^(String.make 1 head)^reset^(loop queue ret (i+1))
        else
          ret ^ (String.make 1 head)^(loop queue ret (i+1))
    in
    loop tape.tape_contents "" 0

  let move_left (tape : t) : t = 
    tape.tape_head <- tape.tape_head - 1;
      if tape.tape_head < 0 then 
      (
        tape.tape_contents <- tape.blank :: tape.tape_contents;
        tape.tape_head <- 0;
      );
      tape

  let move_right (tape : t) : t = 
    tape.tape_head <- tape.tape_head + 1;
    if tape.tape_head >= List.length tape.tape_contents then 
          tape.tape_contents <- tape.tape_contents @ [tape.blank];
    tape

  let read_head (tape : t) : char =
    List.nth tape.tape_contents tape.tape_head

  let write_head (tape : t) (value : char) : t = 
    let updated_list = 
      List.mapi (fun i cell ->
        if i = tape.tape_head then value else cell
      ) tape.tape_contents
    in
    tape.tape_contents <- updated_list;
    tape
    
end

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
  mutable tape : Tape.t option;
  mutable state : string;
  mutable read : char;
}

let create_empty_machine unit : machine = 
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
    read = ' ';
  }  

let create (file: string) (_verbose : bool) :machine option =
  if file = "" then failwith "empty input";
  if _verbose then Printf.printf "Loading \"%s%s%s\" ... " yellow file reset;
  try
    let json = Yojson.Basic.from_file file in
    let _alphabet = Parsing.get_alphabet(json) in
    let _blank = Parsing.get_blank(json) in
    if List.mem _blank _alphabet = false then
      failwith ("Blank caractere '"^(String.make 1 _blank)^"' must be part of Alphabet list.");
    let _states = Parsing.get_states(json) in
    let _initial = Parsing.get_initial(json) in
    if List.mem _initial _states = false then
      failwith "State initial must be part of State list.";
    let _finals = Parsing.get_finals(json) in
    if not (List.for_all (fun final -> List.mem final _states) _finals) then
      failwith "Finals states are not a subset of States list.";
    let transitions_json = Parsing.get_transitions(json) in
    let _transitions = Hashtbl.create (List.length _states) in
    
    (* Parse transitions *)
    let found_halt_state = ref false in
      
    List.iter (fun (state, trans_list) ->
      if not (List.mem state _states) then
          failwith ("State '" ^ state ^ "' in transition not found in the list of states");

      let transitions_list =
        trans_list |> to_list |> List.map (fun trans ->
          let read : char =
            match trans |> member "read" with
            | `String read_str when String.length read_str = 1 -> read_str.[0]
            | _ -> failwith ("Invalid or missing 'read' key in transition of state : " ^ state)
          in
          if not(List.mem read _alphabet) then
            failwith ("read character '"^(String.make 1 read) ^ "' not in alphabet.");
          let to_state : string=
            match trans |> member "to_state" with
            | `String to_state_str -> to_state_str
            | _ -> failwith ("Invalid or missing 'to_state' key in transition of state : " ^ state)
          in
          if not(List.mem to_state _states) then
            failwith ("'" ^ to_state ^ "' not in State list.");
          let write : char =
            match trans |> member "write" with
            | `String write_str when String.length write_str = 1 -> write_str.[0]
            | _ -> failwith ("Invalid or missing 'write' key in transition of state : " ^ state)
          in
          if not(List.mem write _alphabet) then
            failwith ("write character '" ^ (String.make 1 write) ^ "' not in alphabet.");
          let action =
            match trans |> member "action" with
            | `String action_str ->
              (match action_str with
              | "LEFT" -> LEFT
              | "RIGHT" -> RIGHT
              | _ -> failwith "Invalid 'action' value in transition")
            | _ -> failwith ("Invalid or missing 'action' key in transition of state : " ^ state)
          in
          if !found_halt_state = false && List.mem to_state _finals then
            found_halt_state := true;
          { read; to_state; write; action }
        )
      in
      Hashtbl.add _transitions state transitions_list
    ) transitions_json;
    if _verbose then Printf.printf " %s%s%s\n" green "Ok" reset;
    if !found_halt_state = false then
      Printf.printf "%sWarning%s The list of transitions doesn't seem to have any stop states.\n" yellow reset;
    
      Some{
      verbose = _verbose;
      name = Parsing.get_name(json);
      alphabet = _alphabet;
      blank = _blank;
      states = _states;
      initial = _initial;
      finals = _finals;
      transitions = _transitions;
      valid = true;
      tape = None;
      state = _initial;
      read = _blank; (*TODO ????*)
    } 
  with
  | Yojson.Json_error msg -> Printf.printf "Error parsing JSON: %s\n" msg; None
  | ex -> Printf.printf "%sKO\nError: %s%s\n" red (Printexc.to_string ex) reset; None

let is_valid (m : machine) : bool =
  m.valid

let find_transition (trans : transitions) (state_name : string) : transition list =
  Hashtbl.find trans state_name

let print_transitions_for_state (m: machine) (state_name : string) : unit =
  Printf.printf "Transitions for state %s%s%s:\n" blue state_name reset;
  try
    let _trans = find_transition (m.transitions) (state_name) in
    List.iter (fun trans ->
      let a = (match trans.action with LEFT -> "LEFT" | RIGHT -> "RIGHT") in
      Printf.printf "\t%sRead:%s %c, %sTo State:%s %s, %sWrite%s: %c, %sAction:%s %s\n"
        yellow reset trans.read  yellow reset trans.to_state yellow reset trans.write yellow reset a
    ) _trans;
  with
  | Not_found ->
    Printf.printf "State %s%s%s not found in transitions\n" yellow state_name reset  
    
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

let add_tape (m : machine) (str : string) : machine= 
  if str = "" then failwith "empty input";
  if not(is_valid m) then
    failwith ("No machine valide !");
  if String.contains str m.blank then
    failwith ("The blank character '"^(String.make 1 (m.blank))^"' must not be present in the input.");
  if not(is_string_in_alphabet str m.alphabet) then
    failwith "an input character is not present in Alphabet.";
  let new_tape = Tape.create (str) (m.blank) in
  m.tape <- Some(new_tape);
  m.read <- Tape.read_head new_tape;
  m

let get_state (m : machine) : string = 
  m.state

let get_name (m : machine) : string = 
  m.name

let read_head_tape (m : machine) : char = 
  match m.tape with
  | Some tap -> Tape.read_head tap
  | None -> failwith "No tape"

let get_transition (m : machine) : (char * direction * string) =
  let trans_state =  find_transition (m.transitions) (m.state) in
  let read_ = read_head_tape m  in
  let is_equal (transition : transition) (char_to_match : char) : bool =
    transition.read = char_to_match
  in
  let tt = List.find (fun trans -> is_equal trans read_) trans_state in
  (tt.write, tt.action, tt.to_state)

let print_transition_info (m : machine) : unit = 
  let read_ = read_head_tape m  in
  let (w, a, s) = get_transition m in
  Printf.printf "(%s, %c) -> (%s, %c, %s)\n" m.state read_ s w (direction_to_string a)

let move_left (m : machine) :machine=
  match m.tape with
    | None -> failwith "No tape!";
    | Some tap -> m.tape <- Some(Tape.move_left tap); 
      m

let move_right (m : machine) :machine= 
  match m.tape with
  | None -> failwith "No tape!";
  | Some tap -> m.tape <- Some(Tape.move_right tap); 
    m

let tape_to_string (m : machine) : string = 
  match m.tape with
  | None -> failwith "No tape!";
  | Some tap -> yellow^"["^reset^(pad_string_to_length (Tape.to_string tap) 30 m.blank)^yellow^"]"^reset

let reload (m : machine) :machine =
  match m.tape with
  | None -> failwith "No tape!";
  | Some tap -> m.tape <- Some(Tape.reload tap);
    m.state <- m.initial;m

let is_stopped (m: machine) : bool =
  List.mem m.state m.finals

let write (m : machine) (c : char) : machine =
  match m.tape with
  | None -> m
  | Some tap -> 
      let new_tape = Tape.write_head tap c in
        m.tape <- Some(new_tape); m

let step (m : machine) : machine =
  if m.verbose then (
    print_string (tape_to_string m);
    print_transition_info m);
  let (w, a, ns) = get_transition m in
  m.state <- ns;
  match a with
    | LEFT -> move_left (write m w)
    | RIGHT -> move_right (write m w)

let run (m: machine) : int =
  let rec loop (count: int) =
    let m = step m in
    if not(is_stopped m) then loop(count + 1)
    else count
  in 
  if is_valid m then
    begin
      let count = loop (0) in
      let tap = Utils.pad_string_to_length (tape_to_string m) 30 m.blank in
      if m.verbose then (
        print_endline ("Ending -> "^tap);
        Printf.printf "%d operation(s)\n" count);
        count
    end
  else
    begin
      if m.verbose then print_endline "No machine is vald";
      0
    end
    
