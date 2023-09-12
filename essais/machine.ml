(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   machine.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/10 09:37:53 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/12 16:56:07 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Yojson.Basic.Util
open Utils
open Colors

type direction = LEFT | RIGHT

type transition = {
  read: char;
  to_state: string;
  write: char;
  action: direction;
}

type transitions = (string, transition list) Hashtbl.t

class machine =
  object(self)
    val mutable _name : string = ""
    val mutable _alphabet : char list = []
    val mutable _blank : char = '_'
    val mutable _states : string list = []
    val mutable _initial : string = ""
    val mutable _finals : string list = []
    val mutable _transitions : transitions = Hashtbl.create 10  (* Initialize an empty hash table *)
    val mutable _valid : bool = false
    initializer print_endline "Machine created"

    method build (file : string) =
      Printf.printf "Loading \"%s%s%s\" ... " yellow file reset;
      try
        let json = Yojson.Basic.from_file file in
        (*                    name                   *)
        let name =
          try
            let name_json = json |> member "name" in
            if name_json = `Null then
              failwith "Name field is null in JSON"
            else
              to_string name_json
          with
          | Not_found -> failwith "Name field not found in JSON"
        in
        (*                    alphabet                   *)
        let alphabet_json = json |> member "alphabet" in
        if alphabet_json = `Null then
          failwith "Alphabet is null";
        let alphabet =
          match to_list alphabet_json with
          | [] -> failwith "Alphabet is empty."
          | elements ->
            List.map (fun elt ->
              match elt with
              | `String s when String.length s = 1 -> s.[0]
              | `Null -> failwith "Alphabet is null"
              | _ -> failwith "Invalid alphabet element"
            ) elements
        in
        (*                    blank                   *)
        let blank = 
          try
            let blank_json = json |> member "blank" in 
            if blank_json = `Null then
              failwith "blank charactere is Null"
            else
              to_string blank_json 
          with
            | Not_found -> failwith "blank charactere not found"
        in
        if String.length blank != 1 then
          failwith "blank must be a string of length strictly equal to 1." ;
        if List.mem blank.[0] alphabet = false then
          failwith "must be part of Alphabet list.";

          (*                    States                   *)
        let states_json = json |> member "states" in
        if states_json = `Null then
          failwith "States is null or empty.";
        let states = match to_list states_json with
          | [] -> failwith "States is empty."
          | elements -> List.map (fun elt ->
              match elt with
              | `String s -> s
              | `Null -> failwith "States is Null"
              | _ -> failwith "Invalid States element"
          ) elements
        in

                  (*                    Initial                   *)
        let initial = 
          try
            let initial_json = json |> member "initial" in
            if initial_json = `Null then
              failwith "Initial state is Null or not found"
            else
              to_string initial_json
          with
            | Not_found -> failwith "Initial state error";
        in
        if List.mem initial states = false then
          failwith "State initial must be part of State list.";

          (*                    Finals                   *)
        let finals_json = json |> member "finals" in
        if finals_json = `Null then
          failwith "Finals is null or empty.";
        let finals = match to_list finals_json with
          | [] -> failwith "Finals is empty."
          | elements -> List.map (fun elt ->
              match elt with
                | `String s -> s
                | `Null -> failwith "Finals is Null."
                | _ -> failwith "Invalid Finals element."
          ) elements
        in
        if not (List.for_all (fun final -> List.mem final states) finals) then
          failwith "Finals states are not a subset of States list.";
        
           (*                    Transitions                   *)
        let transitions_json =
          try
            let json_member = json |> member "transitions" in
            match json_member with
            | `Null -> failwith "Transitions field is null."
            | `Assoc assoc -> 
                if assoc = [] then
                  failwith "Transitions field is empty in JSON"
                else
                  assoc
            | _ -> failwith "Invalid format for transitions field in JSON"
          with
          | Not_found -> failwith "Transitions field not found in JSON"
        in
        let transitions = Hashtbl.create (List.length states) in

        (* Parse transitions *)
        let found_halt_state = ref false in
        
        List.iter (fun (state, trans_list) ->
          if not (List.mem state states) then
              failwith ("State '" ^ state ^ "' in transition not found in the list of states");

          let transitions_list =
            trans_list |> to_list |> List.map (fun trans ->
              let read : char =
                match trans |> member "read" with
                | `String read_str when String.length read_str = 1 -> read_str.[0]
                | _ -> failwith ("Invalid or missing 'read' key in transition of state : " ^ state)
              in
              if not(List.mem read alphabet) then
                failwith ("read character '"^(String.make 1 read) ^ "' not in alphabet.");
              let to_state : string=
                match trans |> member "to_state" with
                | `String to_state_str -> to_state_str
                | _ -> failwith ("Invalid or missing 'to_state' key in transition of state : " ^ state)
              in
              if not(List.mem to_state states) then
                failwith ("'" ^ to_state ^ "' not in State list.");
              let write : char =
                match trans |> member "write" with
                | `String write_str when String.length write_str = 1 -> write_str.[0]
                | _ -> failwith ("Invalid or missing 'write' key in transition of state : " ^ state)
              in
              if not(List.mem write alphabet) then
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
              if !found_halt_state = false && List.mem to_state finals then
                found_halt_state := true;
              { read; to_state; write; action }
            )
          in
          Hashtbl.add transitions state transitions_list
        ) transitions_json;


        (* Set the parsed values in the object *)
        _name <- name;
        _alphabet <- alphabet;
        _blank <- blank.[0];  (* Assuming blank is a single character *)
        _states <- states;
        _initial <- initial;
        _finals <- finals;
        _transitions <- transitions;
        _valid <- true;
        Printf.printf " %s%s%s\n" green "Ok" reset;
        if !found_halt_state = false then
          Printf.printf "%sWarning%s The list of transitions doesn't seem to have any stop states.\n" yellow reset;
      with
      | Yojson.Json_error msg -> Printf.printf "Error parsing JSON: %s\n" msg
      | ex -> Printf.printf "%sKO\nError: %s%s\n" red (Printexc.to_string ex) reset

    method print : unit =
      if self#is_valid then
        begin
          print_endline "****************************************";
          Printf.printf "*           %s                 \n" _name;
          print_endline "****************************************";
          print_list_char _alphabet "Alphabet";
          Printf.printf "Blank : '%c'\n" _blank;
          print_list_string _states "States";
          Printf.printf "Initial : %s\n" _initial;
          print_list_string _finals "Finals";
          (* List.iter (fun state_name -> self#print_transitions_for_state state_name) _states; *)
          List.iter (fun state_name ->
            if not (List.mem state_name _finals) then
              self#print_transitions_for_state state_name
          ) _states;
        end
      else
        Printf.printf "Machine ... %sNot Valid%s\n" red reset
    
    method is_valid = 
      _valid

    method validation = 
      if List.mem _blank _alphabet = false then
        begin
          Printf.printf "%sKO%s\n\t->Blank character [%s%c%s] must be in Alphabet " red reset yellow _blank reset;
          print_list_char _alphabet "";
          false
        end
      else if List.mem _initial _states = false then
        begin
          Printf.printf "%sKO%s\n\t->Initial state [%s%s%s] must be in States list " red reset yellow _initial reset;
          print_list_string _states "";
          false
        end
      else
        true

    method print_transitions_for_state (state_name : string) : unit =
      Printf.printf "Transitions for state %s:\n" state_name;
      try
        let transitions = Hashtbl.find _transitions state_name in
        List.iter (fun trans ->
          Printf.printf "\tRead: %c, To State: %s, Write: %c, Action: %s\n"
            trans.read trans.to_state trans.write (match trans.action with LEFT -> "LEFT" | RIGHT -> "RIGHT")
        ) transitions;
      with
      | Not_found ->
        Printf.printf "State %s%s%s not found in transitions\n" yellow state_name reset  
  end
