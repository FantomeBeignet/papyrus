open Core_unix
open Sys_unix
open Defaults

let init_project name gitignore =
  let config = Config.make_config ~name () in
  mkdir_p (Filename.concat (Filename.concat name "src") "content");
  mkdir (Filename.concat name "_papyrus");
  Config.dump_config (Filename.concat name (name ^ ".papyrus")) config;
  (if gitignore then
   let oc = Out_channel.open_text (Filename.concat name ".gitignore") in
   Out_channel.output_string oc "_papyrus");
  Printf.printf "Papyrus project \"%s\" created\n" name;
  Out_channel.flush Stdlib.stdout

let init_command name =
  Printf.printf "Welcome to Papyrus!\n";
  (match name with
  | None ->
      Printf.printf "Project name: (default: \"%s\")\n" defaults.name;
      Printf.printf "> "
  | Some s -> Printf.printf "Project name: %s\n" s);
  Out_channel.flush Stdlib.stdout;
  let project_name =
    match name with
    | None -> (
        let input = In_channel.input_line Stdlib.stdin in
        match input with Some s -> s | None -> defaults.name)
    | Some s -> s
  in
  (match is_directory project_name with
  | `No -> ()
  | _ -> (
      Printf.printf "Directory is not empty. Continue anyway? (y/N)\n";
      Printf.printf "> ";
      Out_channel.flush Stdlib.stdout;
      let input = In_channel.input_char Stdlib.stdin in
      match input with
      | Some c when c = 'y' || c = 'Y' -> ()
      | None | Some _ ->
          Printf.printf "Aborting project creation.\n";
          exit 1));
  Printf.printf "Create a .gitignore? (Y/n)\n";
  Printf.printf "> ";
  Out_channel.flush Stdlib.stdout;
  let gitignore =
    let input = In_channel.input_char Stdlib.stdin in
    match input with
    | Some c when c = 'n' || c = 'n' -> false
    | None -> true
    | Some _ -> true
  in
  init_project project_name gitignore
