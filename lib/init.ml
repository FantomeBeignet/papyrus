open Core_unix
open Sys_unix
open Defaults
module C = Cmdliner

let init_project title description language gitignore =
  let config = Config.make_config ~title ~description ~language () in
  mkdir_p (Filename.concat (Filename.concat title "src") "content");
  mkdir (Filename.concat title "_papyrus");
  Config.dump_config (Filename.concat title (title ^ ".papyrus")) config;
  (if gitignore then
     let oc = Out_channel.open_text (Filename.concat title ".gitignore") in
     Out_channel.output_string oc "_papyrus");
  print_endline [%string "Papyrus project %{Filename.quote title} created"];
  Out_channel.flush Stdlib.stdout

let init_cmd title description language gitignore =
  Printf.printf "Welcome to Papyrus!\n";
  (match title with
  | None ->
      print_endline
        [%string "Project name: (default: %{Filename.quote defaults.title})"];
      print_string "> "
  | Some s -> print_endline [%string "Project name: %{Filename.quote s}"]);
  Out_channel.flush Stdlib.stdout;
  let project_name =
    match title with
    | None -> (
        let input = In_channel.input_line Stdlib.stdin in
        match input with Some s -> s | None -> defaults.title)
    | Some s -> s
  in
  (match is_directory project_name with
  | `No -> ()
  | _ -> (
      print_endline "Directory is not empty. Continue anyway? (y/N)";
      print_string "> ";
      Out_channel.flush Stdlib.stdout;
      let input = In_channel.input_char Stdlib.stdin in
      match input with
      | Some c when c = 'y' || c = 'Y' -> ()
      | None | Some _ ->
          print_endline "Aborting project creation.";
          exit 1));
  let _gitignore =
    if not gitignore then (
      print_endline "Create a .gitignore? (Y/n)";
      print_string "> ";
      Out_channel.flush Stdlib.stdout;
      let input = In_channel.input_char Stdlib.stdin in
      match input with
      | Some c when c = 'n' || c = 'n' -> false
      | None -> true
      | Some _ -> true)
    else true
  in
  let _description =
    match description with
    | Some s -> s
    | None -> (
        print_endline "Project description:";
        print_string "> ";
        Out_channel.flush Stdlib.stdout;
        let input = In_channel.input_line Stdlib.stdin in
        match input with Some s -> s | None -> failwith "Exited")
  in
  init_project project_name _description language _gitignore
