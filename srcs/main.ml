(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 10:07:20 by clorin            #+#    #+#             *)
(*   Updated: 2023/10/05 15:45:41 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Ft_turing
open Ft_turing.Colors

let usage_string () : string =
  let usage =
    Printf.sprintf "Usage: ft_turing [-h][-i] [jsonfile input] [-c jsonfile]\n\
                    optional arguments:\n\
                    jsonfile         description of the machine\n\
                    input            input of the machine\n\
                    -h, --help       show this help message and exit\n\
                    -c               return num of operations\n\
                    -i [jsonfile] [input] -> Mode Interactive with commands:\n"
  in
  usage

let main_run_complex (jsonfile:string) (input:string) : int =
  let result =
    try
      match Machine.create jsonfile false with
      | Some m ->
        let m_with_tape = Machine.add_tape m input in
        Machine.run m_with_tape
      | None -> 0
    with
    | Failure msg -> 
        Printf.printf "%sError: %s%s\n" red msg reset; 0
    | ex ->
      Printf.printf "%sError: %s%s\n" red (Printexc.to_string ex) reset;0
  in

  match result with
  | x when x <= 0 -> exit(1)
  | _ -> print_int result; 0

let main_run (jsonfile:string) (input:string) : int =

  let result =
    try
      match Machine.create jsonfile true with
      | Some m ->
        let m_with_tape = Machine.add_tape m input in
        Machine.print m_with_tape;
        Machine.run m_with_tape
      | None -> 0
    with
    | Failure msg -> 
        Printf.printf "%sError: %s%s\n" red msg reset; 0
    | ex ->
      Printf.printf "%sError: %s%s\n" red (Printexc.to_string ex) reset;0
  in

  match result with
  | x when x <= 0 -> exit(1)
  | _ -> result
      
let process_command_line_args (args : string list) : int =
  match args with
  | [] -> 0
  | _ :: args ->
    match args with
    | "-h" :: _ -> print_string (usage_string()); 0
    | "--help" :: _ -> print_string (usage_string()); 0
    | "-c" :: jsonfile :: input :: _ -> main_run_complex jsonfile input
    | "-i" :: jsonfile :: input :: _ -> Interactive_mode.main_interactive_mode jsonfile input
    | "-i" :: jsonfile :: _  -> Interactive_mode.main_interactive_mode jsonfile ""
    | jsonfile :: input :: _ -> main_run jsonfile input
    | _ -> print_string (usage_string()); 0

let () =
  let args = Array.to_list Sys.argv in
  let ret = process_command_line_args args in
  print_endline "";
  exit ret