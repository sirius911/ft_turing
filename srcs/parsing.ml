(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   parsing.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 12:50:41 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/22 13:33:07 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Yojson.Basic.Util

let get_name (json) : string = 
    try
      let name_json = json |> member "name" in
      if name_json = `Null then
        failwith "Name field is null in JSON"
      else
        to_string name_json
    with
    | Not_found -> failwith "Name field not found in JSON"

let get_alphabet (json) : char list = 
  let alphabet_json = json |> member "alphabet" in
  if alphabet_json = `Null then
    failwith "Alphabet is null";
  match to_list alphabet_json with
  | [] -> failwith "Alphabet is empty."
  | elements ->
    List.map (fun elt ->
      match elt with
      | `String s when String.length s = 1 -> s.[0]
      | `Null -> failwith "Alphabet is null"
      | _ -> failwith "Invalid alphabet element"
    ) elements

let get_blank json : char = 
  let blank = 
    try
      let blank_json = json |> member "blank" in 
      if blank_json = `Null then
        failwith "blank charactere is Null"
      else
        to_string blank_json 
    with
      | Not_found -> failwith "blank charactere not found"
  in
  blank.[0]

let get_states json : string list = 
    let states_json = json |> member "states" in
    if states_json = `Null then
      failwith "States is null or empty.";
    match to_list states_json with
      | [] -> failwith "States is empty."
      | elements -> List.map (fun elt ->
          match elt with
          | `String s -> s
          | `Null -> failwith "States is Null"
          | _ -> failwith "Invalid States element"
      ) elements

let get_initial json: string = 
    try
      let initial_json = json |> member "initial" in
      if initial_json = `Null then
        failwith "Initial state is Null or not found"
      else
        to_string initial_json
    with
      | Not_found -> failwith "Initial state error"

let get_finals json: string list = 
  let finals_json = json |> member "finals" in
  if finals_json = `Null then
      failwith "Finals is null or empty.";
  match to_list finals_json with
    | [] -> failwith "Finals is empty."
    | elements -> List.map (fun elt ->
        match elt with
          | `String s -> s
          | `Null -> failwith "Finals contains a null element."
          | _ -> failwith "Invalid Finals element."
    ) elements

let get_transitions json = 
      try
        let json_member = json |> member "transitions" in
        match json_member with
        | `Null -> failwith "Transitions field is null."
        | `Assoc assoc -> 
            if assoc = [] then
              failwith "Transitions field is empty in JSON"
            else
              assoc
        | _ -> failwith "Invalid format for transitions field in JSON"
      with
      | Not_found -> failwith "Transitions field not found in JSON"


