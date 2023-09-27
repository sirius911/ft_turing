(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   types.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/25 14:17:45 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/27 08:37:55 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type direction = LEFT | RIGHT

type transition = {
  read: char;
  to_state: string;
  write: char;
  action: direction;
}

type transitions = (string, transition list) Hashtbl.t
