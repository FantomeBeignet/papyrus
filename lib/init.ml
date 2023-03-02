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

let init_command name =
  Printf.printf "%s\n" "Welcome to Papyrus!";
  (match name with
  | None ->
      Printf.printf "Project name: (default: \"%s\")\n" defaults.name;
      Printf.printf "> "
  | Some s -> Printf.printf "Project name: %s\n" s);
  Out_channel.flush_all ();
  let project_name =
    match name with
    | None -> (
        let input = In_channel.input_line Stdlib.stdin in
        match input with Some s -> s | None -> defaults.name)
    | Some s -> s
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
