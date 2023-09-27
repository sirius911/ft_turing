(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   interactive_mode.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/15 10:04:02 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/27 09:30:32 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Colors
open Machine

let info (m : machine) (verbose : bool) : string =
  if not (Machine.is_valid m) then "{No Machine}"
  else
    let state_str =
      if Machine.is_stopped m then red ^ "STOPPED" ^ reset
      else if not (Machine.have_tape m) then yellow ^ "NO TAPE" ^ reset
      else if Machine.is_valid m then green ^ "ACTIVE" ^ reset
      else red ^ "NOT VALID" ^ reset
    in
    if not verbose then Machine.tape_to_string m ^ " => " ^ state_str
    else
      "\n" ^ blue ^ "Machine" ^ reset ^ "{" ^ Machine.get_name m ^ "} -> state = '"
      ^ state_str ^ "', tape => " ^ Machine.tape_to_string m ^ " => " ^ state_str


let show_commands () : string =
  let command_list =
    [|
      "exit -> to quit";
      "load [jsonfile] -> make new Machine with jsonfile instructions.";
      "input [input] -> load input to the 'tape' of the Machine.";
      "left -> move on left the head of the Machine";
      "right -> move on right the head of the Machine";
      "info -> print the info of the Machine";
      "run -> Run the Machine from its position and state.";
      "step -> Run the Machine in a single step.";
      "transition -> Print the transition found with the actual state and head reading";
      "state -> Print the actual state";
      "reload -> reload tape from initial input";
      "tape -> Print the tape"
    |]
  in
  let commands = String.concat "\n" (Array.to_list command_list) in
  "commands :\n" ^ commands
    
let rec command_loop (m : machine) (refresh: bool): int =
  print_endline (info m refresh);
  Printf.printf "> ";
  try
    let input = read_line () in
    let commands = String.split_on_char ' ' input in
    match commands with
    | [] -> command_loop m false
    | command :: arguments ->
      match command with
      | "" -> command_loop m false
      | "exit" -> 0
      | "load" ->
        (match Machine.create (String.concat "" arguments) true with
        | Some newM -> command_loop newM true
        | None -> command_loop m true)
      | "input" -> command_loop (Machine.add_tape m (String.concat "" arguments)) true
      | "left" -> command_loop (Machine.move_left m) false
      | "right" -> command_loop (Machine.move_right m) false
      | "info" ->
        let () = Machine.print m in
        command_loop m false
      | "run" ->
        let () = ignore (Machine.run m) in
        command_loop m false
      | "step" -> command_loop (Machine.step m) false
      | "transition" ->
        let () = Machine.print_transition_info m in
        command_loop m false
      | "state" ->
        Printf.printf "Actual state is %s%s%s\n" yellow (Machine.get_state m) reset;
        command_loop m false
      | "reload" -> command_loop (Machine.reload m) true
      | "commands" ->
        let () = print_endline (show_commands ()) in
        command_loop m false
      | "tape" -> command_loop m false
      | _ ->
        let () =
          Printf.printf "%sError :%s -> unknown command '%s%s%s'(use commands for help)\n" red reset yellow command reset
        in
        command_loop m false
  with
  | End_of_file -> 0
  | Failure msg ->
    let () = print_endline (red ^ "Error : " ^ reset ^ msg) in
    command_loop m false
  | ex ->
    let () = print_endline (red ^ "Error : " ^ reset ^ Printexc.to_string ex) in
    command_loop m false
  
let main_interactive_mode (jsonfile: string) (input: string) : int =
  Printf.printf "%sInteractive Mode%s (%s)(%s) : tape commands for help.\n" "blue" "reset" jsonfile input;
  let m =
    match jsonfile with
    | "" -> Machine.create_empty_machine()
    | _ ->
      (match Machine.create jsonfile true with
      | Some m ->
        (match input with
        | "" -> m
        | _ -> Machine.add_tape m input)
      | None -> Machine.create_empty_machine())
  in
  command_loop m true
