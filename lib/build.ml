open Core_unix
module Ic = Stdio.In_channel
module Oc = Stdio.Out_channel

let build_file (config : Config.t) source dest =
  Omd.of_string (Ic.read_all source)
  |> Omd.to_html ~pindent:true
  |> Html.make_document ~language:config.language ~title:config.name
       ~description:config.description ~authors:config.authors
  |> Html.prettify
  |> fun c -> Oc.write_all dest ~data:c

let build_project (config : Config.t) =
  mkdir_p (Filename.concat config.build_dir config.base_url);
  let content_dir = Filename.concat "src" "content" in
  let build_root = Filename.concat config.build_dir config.base_url in
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
            build_file config real_file_path
              (Filename.chop_suffix projected_file_path "md" ^ "html");
            aux dir tl
        | _ ->
            Utils.cp real_file_path projected_file_path;
            aux dir tl)
  in
  aux "" (Sys_unix.ls_dir content_dir)

let build_command () =
  let config = Config.find_config () in
  Fmt.set_style_renderer Fmt.stdout `Ansi_tty;
  print_endline "";
  Pp.pp_build_step Fmt.stdout "Starting build with following config:";
  Config.pp Fmt.stdout config;
  build_project config;
  Pp.pp_success Fmt.stdout
    [%string "Project built in %{Filename.quote config.build_dir} directory"]
