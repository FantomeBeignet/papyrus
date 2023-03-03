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
  let build_root = Filename.concat config.build_dir config.root_dir in
  (match Sys_unix.is_directory build_root with
  | `Yes -> ()
  | _ -> mkdir_p build_root);
  let rec aux dir files =
    let build_dir_path = Filename.concat build_root dir in
    (match Sys_unix.is_directory build_dir_path with
    | `Yes -> ()
    | _ -> mkdir_p build_dir_path);
    match files with
    | [] -> ()
    | filename :: tl -> (
        let filepath = Filename.concat dir filename in
        let projected_file_path = Filename.concat build_root filepath in
        let real_file_path = Filename.concat content_dir filepath in
        match Sys_unix.is_directory real_file_path with
        | `Yes ->
            aux filepath (Sys_unix.ls_dir real_file_path);
            aux dir tl
        | _ when Filename.check_suffix filename "md" ->
            build_file real_file_path
              (Filename.chop_suffix projected_file_path "md" ^ "html");
            aux dir tl
        | _ ->
            Utils.cp real_file_path projected_file_path;
            aux dir tl)
  in
  aux "" (Sys_unix.ls_dir content_dir)

let build_command () =
  let config = Config.find_config () in
  print_endline "Starting build with following config:";
  Config.pp config;
  build_project config;
  print_endline
    [%string "Project built in %{Filename.quote config.build_dir} directory"]
