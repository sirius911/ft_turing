(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   parsing.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 12:50:41 by clorin            #+#    #+#             *)
(*   Updated: 2023/10/09 15:42:04 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Yojson.Basic.Util
open Types

let get_string_json (json) (search_chain : string) : string = 
    let chain_json = json |> member search_chain in
    match chain_json with
    | `String s when String.length s = 0 -> failwith(search_chain ^ " field is an empty string in JSON")
    | `Null -> raise (Failure (search_chain ^ " field is null or Not Found in JSON"))
    | _ -> to_string chain_json


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

let get_list_string_json (json) (search_chain : string) : string list =
    let list_json = json |> member search_chain in
    match list_json with
    | `Null -> failwith (search_chain^" is Null or Not Found in JSON")
    | _ -> match to_list list_json with
           | [] -> failwith (search_chain^" is empty")
           | elements -> List.map (fun elt -> 
                match elt with
                | `String s -> s
                | `Null -> failwith ("Empty element in "^search_chain)
                | _ -> failwith ("Invalid element in "^search_chain)
            ) elements

let get_transitions json =
        let json_member = json |> member "transitions" in
        match json_member with
        | `Null -> failwith "Transitions field is null."
        | `Assoc assoc -> 
            if assoc = [] then
              failwith "Transitions field is empty in JSON"
            else
              assoc
        | _ -> failwith "Invalid format for transitions field in JSON"

let fill_transitions json nb_state =
    let _transitions = Hashtbl.create nb_state in
    let transitions_json = get_transitions(json) in
    List.iter (fun (state, trans_list) ->
      let transitions_list =
        trans_list |> to_list |> List.map (fun trans ->
          let read : char =
            match trans |> member "read" with
            | `String read_str when String.length read_str = 1 -> read_str.[0]
            | _ -> failwith ("Invalid or missing 'read' key in transition of state : " ^ state)
          in
          let to_state : string=
            match trans |> member "to_state" with
            | `String to_state_str -> to_state_str
            | _ -> failwith ("Invalid or missing 'to_state' key in transition of state : " ^ state)
          in
          let write : char =
            match trans |> member "write" with
            | `String write_str when String.length write_str = 1 -> write_str.[0]
            | _ -> failwith ("Invalid or missing 'write' key in transition of state : " ^ state)
          in
          let action =
            match trans |> member "action" with
            | `String action_str ->
              (match action_str with
              | "LEFT" -> LEFT
              | "RIGHT" -> RIGHT
              | _ -> failwith "Invalid 'action' value in transition")
            | _ -> failwith ("Invalid or missing 'action' key in transition of state : " ^ state)
          in
          { read; to_state; write; action }
        )
      in
      Hashtbl.add _transitions state transitions_list
    ) transitions_json;
  _transitions

let parser json = 
  let _blank_str = (get_string_json(json) "blank") in
  if String.length _blank_str > 1 then
    failwith ("Blank caractere must be a char.");
  let _blank = _blank_str.[0] in
  let _states = get_list_string_json (json) "states" in
  (
    get_string_json(json) "name",
    get_alphabet json,
    _blank,
    _states,
    get_string_json(json) "initial",
    get_list_string_json (json) "finals",
    fill_transitions json (List.length _states)
  )