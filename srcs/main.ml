(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/10 10:24:16 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/15 13:22:15 by clorin           ###   ########.fr       *)
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


let main_run (jsonfile:string) (input:string) : unit =
  let myMachine = new Machine.machine in
  myMachine#build jsonfile;
  myMachine#add_tape input;
  myMachine#print;
  myMachine#run()

let () =
  match Array.to_list Sys.argv with
  | [] -> ()
  | _ :: args ->
    match args with
    | "-h" :: _ -> print_usage ()
    | "--help" :: _ -> print_usage ()
    | "-c" :: jsonfile :: _ -> (* Handle -c option *)
      Printf.printf "Calculating complexity for %s\n" jsonfile
    | "-i" :: jsonfile :: input ::_-> Interactive_mode.main_interactive_mode (jsonfile) (input);
    | "-i" :: jsonfile :: _  -> 
        Interactive_mode.main_interactive_mode (jsonfile) "";
    | jsonfile :: input :: _ -> (* Handle jsonfile and input arguments *)
      main_run jsonfile input
    | _ -> print_usage();
  print_endline ""


(* let () =  *)
  (* let myMachine = new Machine.machine in   *)
(*   
  let tape = "111-1=" in
  myMachine#build "../machines/unary_sub.json";
  
  myMachine#add_tape tape;
  myMachine#print;
  
  myMachine#run(); *)

  (* myMachine#build "../machines/0n1n.json";
  myMachine#add_tape "000111";
  myMachine#print;
  myMachine#run();
  print_endline "end" *)