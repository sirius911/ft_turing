(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   tape.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/13 11:00:06 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/22 11:25:53 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Colors

module Tape = 
struct
  type t = {
    mutable tape_contents : char list;
    mutable tape_head : int;
    blank : char;
    input : string;
  }

  let create (initial_string : string) (blank : char) =
    {
      tape_contents = List.of_seq (String.to_seq initial_string);
      tape_head = 0;
      blank = blank;
      input = initial_string;
    }
  
  let init (tape : t) (initial_string : string) : t =
    tape.tape_contents <- List.of_seq (String.to_seq initial_string);
    tape

  let reload (tape : t) : t =
    tape.tape_head <- 0; 
    init tape tape.input
      
  let print (tape : t) : unit =
    List.iteri (fun i cell ->
      if i = tape.tape_head then Printf.printf "<%s%c%s>" "\x1b[31m" cell "\x1b[0m"
      else print_char cell) tape.tape_contents;
    print_newline ()

  let to_string (tape : t) : string = 
    let rec loop liste ret i = match liste with
      | [] -> ret
      | head::queue -> 
        if i = tape.tape_head then
          ret ^red^(String.make 1 head)^reset^(loop queue ret (i+1))
        else
          ret ^ (String.make 1 head)^(loop queue ret (i+1))
    in
    loop tape.tape_contents "" 0

  let move_left (tape : t) : t = 
    tape.tape_head <- tape.tape_head - 1;
      if tape.tape_head < 0 then 
      (
        tape.tape_contents <- tape.blank :: tape.tape_contents;
        tape.tape_head <- 0;
      );
      tape

  let move_right (tape : t) : t = 
    tape.tape_head <- tape.tape_head + 1;
    if tape.tape_head >= List.length tape.tape_contents then 
          tape.tape_contents <- tape.tape_contents @ [tape.blank];
    tape

  let read_head (tape : t) : char =
    List.nth tape.tape_contents tape.tape_head

  let write_head (tape : t) (value : char) : t = 
    let updated_list = 
      List.mapi (fun i cell ->
        if i = tape.tape_head then value else cell
      ) tape.tape_contents
    in
    tape.tape_contents <- updated_list;
    tape
    
end