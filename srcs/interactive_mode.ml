(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   interactive_mode.ml                                :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/15 10:04:02 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/15 13:24:21 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Colors

let info (myMachine : Machine.machine)(verbose:bool): string = 
  if myMachine#is_valid() = false then "{No Machine}" 
  else if  verbose = false then
      myMachine#tape_to_string()
  else
    (
      let retour = ref ("\n"^blue^"Machine"^reset^"{" ^ myMachine#get_name() ^ "} -> state = '") in
      if myMachine#is_stopped() then
        retour := !retour ^ red
      else 
        retour := !retour ^ green;
      retour := !retour ^ myMachine#get_state() ^ reset ^ "', tape => " ^ myMachine#tape_to_string();
      if myMachine#is_stopped() then
        (!retour ^ red ^ " => STOPPED"^reset)
      else if not(myMachine#have_tape()) then
        (!retour ^ yellow ^ " => NO TAPE"^reset)
      else if myMachine#is_valid() then
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
    
let rec command_loop (myMachine : Machine.machine) (refresh:bool)=
  try
    print_endline(info myMachine refresh);
    Printf.printf "> ";
    let commands = String.split_on_char ' ' (try read_line () with End_of_file -> "exit") in
    match commands with
    | [] -> command_loop (myMachine) false
    | command :: arguments ->
        match command with
        | "" -> command_loop myMachine false
        | "exit" -> ()
        | "load" ->
          myMachine#build (String.concat "" arguments); command_loop myMachine true
        | "input" -> 
          myMachine#add_tape (String.concat ""arguments); command_loop myMachine true
        | "left" -> myMachine#move_left(); command_loop myMachine false
        | "right" -> myMachine#move_right(); command_loop myMachine false
        | "info" -> myMachine#print; command_loop myMachine false
        | "run" -> myMachine#run(); command_loop myMachine false
        | "step" -> myMachine#step(); command_loop myMachine false
        | "transition" -> myMachine#print_transition_info(); command_loop myMachine false
        | "state" -> Printf.printf "Actual state is %s%s%s\n" yellow (myMachine#get_state()) reset; command_loop myMachine false
        | "reload" -> myMachine#reload(); command_loop myMachine true
        | "commands" -> show_commands(); command_loop myMachine false
        | "tape" -> command_loop myMachine false
        | _ -> Printf.printf "%sError :%s -> unknown command '%s%s%s'(use commands for help)\n" red reset yellow command reset ;command_loop myMachine false
  with
    | Failure msg -> 
        print_endline (red^"Error : "^ reset ^ msg);
        command_loop myMachine false
    | ex ->
        print_endline (red^"Error : " ^reset^ Printexc.to_string ex);
        command_loop myMachine false

let main_interactive_mode (jsonfile:string)(input:string) : unit =
  let myMachine = new Machine.machine in
  Printf.printf "%sInteractive Mode%s (%s)(%s) : tape commands for help.\n"blue reset jsonfile input;
  if jsonfile <> "" then
    myMachine#build jsonfile;
  if input <> "" then
    myMachine#add_tape input;
  command_loop (myMachine) true
