(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   tape.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/13 11:00:06 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/14 10:18:07 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Colors

class tape (initial_string : string) (blank : char) =
  object(self)
    val mutable _tape_contents = List.of_seq (String.to_seq initial_string)
    val mutable _tape_head = 0
    val _blank = blank

    method init_tape (initial_string : string) = 
      _tape_contents <- List.of_seq (String.to_seq initial_string)
    
    method move_left () : char =
      _tape_head <- _tape_head - 1;
      if _tape_head < 0 then 
      (
        _tape_contents <- _blank :: _tape_contents;
        _tape_head <- 0;
      );
      self#read_head()

    method move_right () : char  =
      _tape_head <- _tape_head + 1;
      if _tape_head >= List.length _tape_contents then 
        _tape_contents <- _tape_contents @ [_blank];
      self#read_head()
      
    method read_head () : char = 
      List.nth _tape_contents _tape_head

    method write_head value : unit = 
      let updated_list = 
        List.mapi (fun i cell ->
          if i = _tape_head then value else cell
        ) _tape_contents
      in
      _tape_contents <- updated_list

    method print () :unit = 
      List.iteri (fun i cell -> 
        if i = _tape_head then Printf.printf"<%s%c%s>" red cell reset else print_char cell) _tape_contents;
      print_newline ()

    method to_string () : string = 
      let rec loop liste ret i = match liste with
        | [] -> ret
        | head::queue -> 
          if i = _tape_head then
            ret ^ "<"^red^(String.make 1 head)^reset^">" ^ (loop queue ret (i+1))
          else
            ret ^ (String.make 1 head)^(loop queue ret (i+1))
      in
      loop _tape_contents "" 0
  end
