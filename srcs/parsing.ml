(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   parsing.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/22 12:50:41 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/28 09:56:58 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Yojson.Basic.Util

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
