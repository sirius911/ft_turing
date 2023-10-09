(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   utils.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/11 10:04:52 by clorin            #+#    #+#             *)
(*   Updated: 2023/10/09 21:22:01 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Types

let verboser (str:string) (verbose:bool): unit =
  match verbose with
  | true -> print_string(str)
  | false -> ()

let print_list_string (liste: string list) (label: string) : unit =
  let formatted_list = List.map (fun s -> "\"" ^ s ^ "\"") liste in
  let result = String.concat ", " formatted_list in
  print_endline (label ^ " : [ " ^ result ^ " ]")

let print_list_char(liste: char list) (label: string) :unit =
  let formatted_list = List.map (String.make 1) liste in
  let result = String.concat ", " formatted_list in
  print_endline (label ^ " : [ " ^ result ^ " ]")

let pad_string_to_length (str : string) (length : int) (blank : char) : string=
  let str_length = String.length str in
  if str_length >= length then
    str
  else
    str ^ String.make (length - str_length) blank

let is_string_in_alphabet s alphabet =
  let string_chars = List.init (String.length s) (String.get s) in
  List.for_all (fun c -> List.mem c alphabet) string_chars
  
let direction_to_string (dir : direction) : string =
  match dir with
  | LEFT -> "Left"
  | RIGHT -> "Right"