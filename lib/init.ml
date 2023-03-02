open Core_unix
open Defaults

let init_project name gitignore =
  let config = Config.make_config ~name () in
  mkdir_p (Filename.concat (Filename.concat name "src") "content");
  mkdir (Filename.concat name "_papyrus");
  Config.dump_config (Filename.concat name (name ^ ".papyrus")) config;
  if gitignore then
    let oc = Out_channel.open_text (Filename.concat name ".gitignore") in
    Out_channel.output_string oc "_papyrus"

let init_command =
  Printf.printf "%s\n" "Welcome to Papyrus!";
  Printf.printf "%s\n" ("Project name: (default: \"" ^ defaults.name ^ "\")");
  Printf.printf "> ";
  Out_channel.flush_all ();
  let project_name =
    let input = In_channel.input_line Stdlib.stdin in
    match input with Some s -> s | None -> defaults.name
  in
  Printf.printf "%s\n" "Create a .gitignore? (Y/n)";
  Printf.printf "> ";
  Out_channel.flush_all ();
  let gitignore =
    let input = In_channel.input_char Stdlib.stdin in
    match input with
    | Some c when c = 'n' || c = 'n' -> false
    | None -> true
    | Some _ -> true
  in
  init_project project_name gitignore
