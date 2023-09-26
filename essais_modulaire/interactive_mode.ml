(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   interactive_mode.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/15 10:04:02 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/26 18:00:45 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Colors
open Machine

let info (m : machine)(verbose : bool) : string = 
  if not(Machine.is_valid m) then "{No Machine}"
  else if not(verbose) then (
    let retour = ref (Machine.tape_to_string m) in
    if (Machine.is_stopped m ) then
      (!retour ^ red ^ " => STOPPED"^reset)
    else
      !retour
    )
  else
    (
      let retour = ref ("\n"^blue^"Machine"^reset^"{" ^ (Machine.get_name m) ^ "} -> state = '") in
      if Machine.is_stopped m then
        retour := !retour ^ red
      else
        retour := !retour ^ green;
      retour := !retour ^ (Machine.get_state m) ^ reset ^ "', tape => " ^(Machine.tape_to_string m);
      if Machine.is_stopped m then
        (!retour ^ red ^ " => STOPPED"^reset)
      else if not(Machine.have_tape m) then
        (!retour ^ yellow ^ " => NO TAPE"^reset)
      else if (Machine.is_valid m) then
        (!retour ^ green ^ " => ACTIVE"^reset)
      else
        (!retour ^ red ^ " => NOT VALID"^reset)
    )

let show_commands () : unit = 
    print_endline " commands : ";
    print_endline ("\t| "^yellow^"exit"^reset^" -> to quit");
    print_endline ("\t| "^yellow^"load"^reset^" [jsonfile] -> make new Machine with jsonfile instructions.");
    print_endline ("\t| "^yellow^"input"^reset^" [input] -> load input to the 'tape' of the Machine.");
    print_endline ("\t| "^yellow^"left"^reset^" -> move on left the head of the Machine");
    print_endline ("\t| "^yellow^"right"^reset^" -> move on right the head of the Machine");
    print_endline ("\t| "^yellow^"info"^reset^" -> print the info of the Machine");
    print_endline ("\t| "^yellow^"run"^reset^" -> Run the Machine from its position and state.");
    print_endline ("\t| "^yellow^"step"^reset^" -> Run the Machine in a single step.");
    print_endline ("\t| "^yellow^"transition"^reset^" -> Print the transition found with the actual state and head reading");
    print_endline ("\t| "^yellow^"state"^reset^" -> Print the actual state");
    print_endline ("\t| "^yellow^"reload"^reset^" -> reload tape from initial input");
    print_endline ("\t| "^yellow^"tape"^reset^" -> Print the tape")
    
let rec command_loop (m : machine) (refresh:bool): int=
  try
    print_endline(info m refresh);
    Printf.printf "> ";
    let commands = String.split_on_char ' ' (try read_line () with End_of_file -> "exit") in
    match commands with
    | [] -> command_loop (m) false
    | command :: arguments ->
        match command with
        | "" -> command_loop m false
        | "exit" -> 0
        | "load" -> (let newMachine = Machine.create (String.concat "" arguments) true in
          match newMachine with
            | Some newM -> command_loop newM true
            | None -> command_loop m true);
        | "input" -> 
          command_loop (Machine.add_tape m (String.concat ""arguments)) true
          (* myMachine#add_tape (String.concat ""arguments); command_loop myMachine true *)
        | "left" -> command_loop (Machine.move_left m) false
        | "right" -> command_loop (Machine.move_right m) false
        | "info" -> Machine.print m; command_loop m false
        | "run" -> ignore(Machine.run m); command_loop m false
        | "step" -> command_loop (Machine.step m) false
        | "transition" -> Machine.print_transition_info m; command_loop m false
        | "state" -> Printf.printf "Actual state is %s%s%s\n" yellow (Machine.get_state m) reset; command_loop m false
        | "reload" -> command_loop (Machine.reload m) true
        | "commands" -> show_commands(); command_loop m false
        | "tape" -> command_loop m false
        | _ -> Printf.printf "%sError :%s -> unknown command '%s%s%s'(use commands for help)\n" red reset yellow command reset ;command_loop m false
  with
    | Failure msg -> 
        print_endline (red^"Error : "^ reset ^ msg);
        command_loop m false
    | ex ->
        print_endline (red^"Error : " ^reset^ Printexc.to_string ex);
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
