open Core
open Core_unix
module Ic = Stdio.In_channel
module Oc = Stdio.Out_channel
module C = Cmdliner

let build_file (config : Config.t) source dest =
  Ic.read_all source
  |> Html.render_page ~config
  |> fun c -> Oc.write_all dest ~data:c

let build_project (config : Config.t) =
  mkdir_p (Utils.concat_paths config.build_dir config.base_url);
  let content_dir = Utils.concat_paths "src" "content" in
  let build_root = Utils.concat_paths config.build_dir config.base_url in
  let routes_map = Config.routes_to_map config.routes in
  let map_filename path =
    let dirname = Filename.dirname path and basename = Filename.basename path in
    match Map.find routes_map basename with
    | Some r -> Utils.concat_paths dirname r
    | None -> Filename.chop_suffix path ".md"
  in
  (match Sys_unix.is_directory build_root with
  | `Yes -> ()
  | _ -> mkdir_p build_root);
  let rec aux dir files =
    let build_dir_path = Utils.concat_paths build_root dir in
    (match Sys_unix.is_directory build_dir_path with
    | `Yes -> ()
    | _ -> mkdir_p build_dir_path);
    match files with
    | [] -> ()
    | filename :: tl -> (
        let filepath = Utils.concat_paths dir filename in
        let projected_file_path = Utils.concat_paths build_root filepath in
        let real_file_path = Utils.concat_paths content_dir filepath in
        match Sys_unix.is_directory real_file_path with
        | `Yes ->
            aux filepath (Sys_unix.ls_dir real_file_path);
            aux dir tl
        | _ when Filename.check_suffix filename "md" ->
            build_file config real_file_path
              (map_filename projected_file_path ^ ".html");
            aux dir tl
        | _ ->
            Utils.cp real_file_path projected_file_path;
            aux dir tl)
  in
  aux "" (Sys_unix.ls_dir content_dir)

let build_cmd () =
  let config = Config.find_config () in
  Fmt.set_style_renderer Fmt.stdout `Ansi_tty;
  print_endline "";
  Pp.pp_build_step Fmt.stdout "Starting build with following config:";
  Config.pp Fmt.stdout config;
  build_project config;
  Pp.pp_success Fmt.stdout
    [%string "Project built in %{Filename.quote config.build_dir} directory"]

