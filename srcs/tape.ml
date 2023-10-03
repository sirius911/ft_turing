(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   tape.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/13 11:00:06 by clorin            #+#    #+#             *)
(*   Updated: 2023/10/03 09:54:56 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* open Colors *)

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