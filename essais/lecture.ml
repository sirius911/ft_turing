open Yojson.Basic

let () = 
  let json_content = read_json_file "exemple.json" in

  match json_content with
  | `Assoc fields ->
    let nom = List.assoc "nom" fields in
    let age = List.assoc "age" fields in
    let ville = List.assoc "ville" fields in

    Printf.printf "Nom : %s\n" (Yojson.Basic.to_string nom);
    Printf.printf "Âge : %d\n" (Yojson.Basic.to_int age);
    Printf.printf "Ville : %s\n" (Yojson.Basic.to_string ville);
  | _ ->
    Printf.eprintf "Le fichier JSON doit être un objet.\n";
    raise Exit
