open Core_unix
module Ic = Stdio.In_channel
module Oc = Stdio.Out_channel

let build_file from _to =
  let doc = Omd.of_string (Ic.read_all from) in
  let html = Omd.to_html ~pindent:true doc in
  Oc.write_all _to ~data:html

let build_project (config : Config.t) =
  mkdir_p (Filename.concat config.build_dir config.root_dir);
  let content_dir = Filename.concat "src" "content" in
  let build_dir = Filename.concat config.build_dir config.root_dir in
  (match Sys_unix.is_directory build_dir with
  | `Yes -> ()
  | _ -> mkdir_p build_dir);
  let rec aux = function
    | [] -> ()
    | hd :: tl -> (
        let filename = Filename.concat content_dir hd in
        match Sys_unix.is_directory filename with
        | `Yes ->
            aux (Sys_unix.ls_dir filename);
            aux tl
        | _ when Filename.check_suffix hd "md" ->
            build_file filename
              (Filename.concat build_dir
                 (Filename.chop_suffix hd "md" ^ "html"));
            aux tl
        | _ -> aux tl)
  in
  aux (Sys_unix.ls_dir content_dir)

let build_command () =
  let config = Config.find_config () in
  print_endline "Starting build with following config:";
  Config.pp config;
  build_project config;
  print_endline
    [%string "Project built in %{Filename.quote config.build_dir} directory"]
