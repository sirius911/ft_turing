(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   machine.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 11:39:01 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/29 09:30:34 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Types
open Colors
open Tape
open Yojson.Basic.Util
open Utils

module Tape = 
struct
  type t = {
    tape_contents : char list;
    tape_head : int;
    blank : char;
    input : string;
  }

  let create (initial_string : string) (blank : char) =
    let tape_contents = List.of_seq (String.to_seq initial_string) in
    {
      tape_contents = tape_contents;
      tape_head = 0;
      blank = blank;
      input = initial_string;
    }
  
  let init (tape : t) (initial_string : string) : t =
    { tape with tape_contents = List.of_seq (String.to_seq initial_string) }

  let reload (tape : t) : t =
    let new_tape_contents = List.of_seq (String.to_seq tape.input) in
  { tape with tape_head = 0; tape_contents = new_tape_contents }
      
  let print (tape : t) : unit =
    let result =
      List.mapi (fun i cell ->
        if i = tape.tape_head then Printf.sprintf "<%s%c%s>" "\x1b[31m" cell "\x1b[0m"
        else String.make 1 cell
      ) tape.tape_contents
    in
    let tape_string = String.concat "" result in
    print_endline tape_string
  
  let to_string (tape : t) : string = 
    let rec loop tape_contents i acc =
      match tape_contents with
      | [] -> acc
      | head :: tail ->
        let cell_str =
          if i = tape.tape_head then
            Printf.sprintf "<%s%c%s>" "\x1b[31m" head "\x1b[0m"
          else
            String.make 1 head
        in
        loop tail (i + 1) (acc ^ cell_str)
    in
    loop tape.tape_contents 0 ""

  let move_left (tape : t) : t = 
    let new_tape_contents, new_tape_head =
      if tape.tape_head > 0 then
        (tape.tape_contents, tape.tape_head - 1)
      else
        (tape.blank :: tape.tape_contents, 0)
    in
    { tape with tape_contents = new_tape_contents; tape_head = new_tape_head }

  let move_right (tape : t) : t = 
    let new_tape_contents, new_tape_head =
      if tape.tape_head < List.length tape.tape_contents - 1 then
        (tape.tape_contents, tape.tape_head + 1)
      else
        (tape.tape_contents @ [tape.blank], tape.tape_head + 1)
    in
    { tape with tape_contents = new_tape_contents; tape_head = new_tape_head }

  let read_head (tape : t) : char =
    List.nth tape.tape_contents tape.tape_head

  let write_head (tape : t) (value : char) : t = 
    let updated_list =
      List.mapi (fun i cell ->
        if i = tape.tape_head then value else cell
      ) tape.tape_contents
    in
    { tape with tape_contents = updated_list }
    
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
    let _blank = (Parsing.get_string_json(json) "blank").[0] in
    if List.mem _blank _alphabet = false then
      failwith ("Blank caractere '"^(String.make 1 _blank)^"' must be part of Alphabet list.");
    let _states = Parsing.get_list_string_json (json) "states" in
    let _initial = Parsing.get_string_json(json) "initial" in
    if List.mem _initial _states = false then
      failwith "State initial must be part of State list.";
    let _finals = Parsing.get_list_string_json (json) "finals" in
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
      name = Parsing.get_string_json(json) "name";
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
  | ex -> Printf.printf "%sKOO\nError: %s%s\n" red (Printexc.to_string ex) reset; None

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
      m with
      tape = Some new_tape;
      read = Tape.read_head new_tape;
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
  

let print_transition_info (m : machine) : unit = 
  let read_ = read_head_tape m  in
  let (w, a, s) = get_transition m in
  Printf.printf "(%s, %c) -> (%s, %c, %s)\n" m.state read_ s w (direction_to_string a)

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
  | None -> failwith "No tape!";
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

let step (m : machine) : machine =
  if m.verbose then (
    print_string (tape_to_string m);
    print_transition_info m);
  let (w, a, ns) = get_transition m in
  m.state <- ns;
  match a with
    | LEFT -> move_left (write m w)
    | RIGHT -> move_right (write m w)

let rec run (m: machine) : int =
  let rec loop (count: int) (machine: machine) =
    if not (is_valid machine) then
      (
        if m.verbose then print_endline "No machine is valid";
        count
      )
    else if is_stopped machine then
      (
        if m.verbose then (
          let tap = Utils.pad_string_to_length (tape_to_string machine) 30 m.blank in
          print_endline ("Ending -> " ^ tap);
          Printf.printf "%d operation(s)\n" count
        );
        count
      )
    else
      loop (count + 1) (step machine)
  in
  loop 0 m

    
