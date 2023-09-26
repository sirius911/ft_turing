(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 10:07:20 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/26 10:07:47 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Colors

let print_usage () =
  Printf.printf "Usage: ft_turing [-h][-i] [jsonfile input] [-c jsonfile]\n";
  Printf.printf "optional arguments:\n";
  Printf.printf "  jsonfile         description of the machine\n";
  Printf.printf "  input            input of the machine\n";
  Printf.printf "  -h, --help       show this help message and exit\n";
  Printf.printf "  -c, --complex    calcul complexity of jsonfile\n";
  Printf.printf "  -i [jsonfile] [input] -> Mode Interactive with commands:\n"

let main_run_complex (jsonfile:string) (input:string) : int =
  try
    let myMachine = Machine.create jsonfile false in
    match myMachine with
      | Some m -> 
        let m = Machine.add_tape m input in
        let ret = Machine.run m in
        print_int ret;
        ret
      | None -> 0

  with 
    | Failure msg -> 
      print_endline (red^"Error : "^ reset ^ msg);
      exit(0)
    | ex ->
      print_endline (red^"Error : " ^reset^ Printexc.to_string ex);
      exit(0)

let main_run (jsonfile:string) (input:string) : unit =
  try
    let myMachine = Machine.create jsonfile true in
    match myMachine with
      | Some m -> 
        let m = Machine.add_tape m input in
        Machine.print m;
        ignore(Machine.run m)
      | None -> ()
  with 
    | Failure msg -> 
      print_endline (red^"Error : "^ reset ^ msg);
      exit(1)
    | ex ->
      print_endline (red^"Error : " ^reset^ Printexc.to_string ex);
      exit(1)

let () =
let ret = ref 0 in
  match Array.to_list Sys.argv with
  | [] -> exit 0
  | _ :: args ->
    match args with
    | "-h" :: _ -> print_usage ()
    | "--help" :: _ -> print_usage ()
    | "-c" :: jsonfile :: input :: _ ->       ret := main_run_complex jsonfile input
    | "-i" :: jsonfile :: input ::_-> Interactive_mode.main_interactive_mode (jsonfile) (input);
    | "-i" :: jsonfile :: _  ->       Interactive_mode.main_interactive_mode (jsonfile) "";
    | jsonfile :: input :: _ ->       main_run jsonfile input
    | _ -> print_usage();
  print_endline "";
  exit !ret

(* open Tape
open Machine

let () =
  let m = ref (Machine.create("../machines/0n1n.json") (true) )in
  
  match !m with
  | None -> print_endline("Machine is None");
  | Some machine -> 
      Machine.print machine;
      let machine = Machine.add_tape machine "0011" in
      Printf.printf "have a tape : %b\n" ( Machine.have_tape machine);
      print_endline (Machine.tape_to_string machine);
      let machine = Machine.move_right machine in
      print_endline (Machine.tape_to_string machine);
      let machine = Machine.move_right machine in
      print_endline (Machine.tape_to_string machine);
      print_endline (Machine.get_state machine);
      print_char (Machine.read_head_tape machine);
      let machine = Machine.reload machine in
      print_endline (Machine.tape_to_string machine);
      print_char (Machine.read_head_tape machine);
      let (a,b,c) = Machine.get_transition machine in
      let f = (match b with LEFT -> "LEFT" | RIGHT -> "RIGHT") in
      Printf.printf "a = %c, b = %s, d = %s\n" a f c;
     Machine.print_transition_info machine;
     let machine = Machine.move_right machine in
      print_endline (Machine.tape_to_string machine);
      let machine = Machine.write machine 'x' in
      print_endline (Machine.tape_to_string machine);
      Printf.printf "Head tape = %c\n" (Machine.read_head_tape machine);
      print_endline "Reload";
      let machine = Machine.reload machine in
      (* let machine = Machine.step machine in
      print_endline (Machine.tape_to_string machine); *)
      (* ignore(Machine.run machine); *)
    
      (* let mytape = Tape.create "ABC" '.' in
  Tape.print mytape;
  let mytape = Tape.move_left mytape in
  Tape.print mytape;
  let mytape = Tape.move_right mytape in
  Tape.print mytape;
  let mytape = Tape.move_right mytape in
  Tape.print mytape;
  let mytape = Tape.move_right mytape in
  Tape.print mytape;
  let mytape = Tape.move_right mytape in
  Tape.print mytape;
  let mytape = Tape.write_head mytape 'X' in
  Tape.print mytape;
  let str = Tape.to_string mytape in
  Printf.printf "Tape Contents: %s\n" str;
  let mytape = Tape.move_left mytape in
  Tape.print mytape;
  print_string "Sous la tete de lecture = ";
  print_char (Tape.read_head mytape); *)


  print_endline ("\nend") *)