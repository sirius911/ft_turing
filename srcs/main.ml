(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/10 10:24:16 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/17 21:34:20 by clorin           ###   ########.fr       *)
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
  try
    myMachine#build jsonfile;
    myMachine#add_tape input;
    myMachine#print;
    myMachine#run()
  with 
    | Failure msg -> 
      print_endline (red^"Error : "^ reset ^ msg);
      exit(1)
    | ex ->
      print_endline (red^"Error : " ^reset^ Printexc.to_string ex);
      exit(1)

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