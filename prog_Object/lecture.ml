(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   lecture.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: clorin <clorin@student.42.fr>              +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2023/09/09 15:16:42 by clorin            #+#    #+#             *)
(*   Updated: 2023/09/09 15:30:42 by clorin           ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open Yojson.Basic

let read_json_file file_name =
  try
    let json_content = Yojson.Basic.from_file file_name in
    json_content
  with
  | Sys_error msg ->
    Printf.eprintf "Erreur lors de la lecture du fichier : %s\n" msg;
    raise Exit
  | Yojson.Json_error msg ->
    Printf.eprintf "Erreur de syntaxe JSON : %s\n" msg;
    raise Exit

let () = 
  let json_content = read_json_file "exemple.json" in

match json_content with
| `Assoc fields ->
  let nom = List.assoc "nom" fields in
  let age = List.assoc "age" fields in
  let ville = List.assoc "ville" fields in

  Printf.printf "Nom : %s\n" (Yojson.Basic.to_string nom);
  Printf.printf "Âge : %s\n" (Yojson.Basic.to_string age);
  Printf.printf "Ville : %s\n" (Yojson.Basic.to_string ville);
| _ ->
  Printf.eprintf "Le fichier JSON doit être un objet.\n";
  raise Exit
