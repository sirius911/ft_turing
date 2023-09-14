(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/10 10:24:16 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/14 12:26:38 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let () = 
  let myMachine = new Machine.machine in  
(*   
  let tape = "111-1=" in
  myMachine#build "../machines/unary_sub.json";
  
  myMachine#add_tape tape;
  myMachine#print;
  
  myMachine#run(); *)

  myMachine#build "../machines/0n1n.json";
  myMachine#add_tape "00110";
  myMachine#print;
  myMachine#run();
  print_endline "end"