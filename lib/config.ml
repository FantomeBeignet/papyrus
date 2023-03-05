open Core
open Core_unix
open Defaults

type t = {
  title : string; [@default defaults.title]
  description : string; [@default defaults.description]
  authors : string list; [@sexp.list]
  language : string; [@default defaults.language]
  base_url : string; [@default ""] [@sexp_drop_default String.equal]
  build_dir : string; [@default "_papyrus"] [@sexp_drop_default String.equal]
  routes : (string * string) list; [@sexp.list]
}
[@@deriving sexp, fields]

let load_config file = Sexp.load_sexp_conv_exn file t_of_sexp
let default_config = Sexp.of_string "()" |> t_of_sexp

let make_config ?(title = defaults.title) ?(description = defaults.description)
    ?(language = defaults.language) () =
  { default_config with title; description; language }

let find_config () =
  let cwd = getcwd () in
  let config_file =
    let rec aux = function
      | [] -> None
      | hd :: _ when Filename.check_suffix hd "papyrus" -> Some (load_config hd)
      | _ :: tl -> aux tl
    in
    aux (Sys_unix.ls_dir cwd)
  in
  match config_file with
  | None ->
      Pp.pp_error Fmt.stdout "No config file found";
      exit 1
  | Some c -> c

let pp formatter config =
  let max_field_length =
    let rec aux acc = function
      | [] -> acc
      | hd :: tl when String.length hd > acc -> aux (String.length hd) tl
      | _ :: tl -> aux acc tl
    in
    aux 0 Fields.names
  in
  let open Fmt in
  let make_spaces field_name =
    sps (max_field_length - String.length field_name + 1)
  in
  let label = styled `Bold (styled (`Fg `Blue) string) in
  let value_style = styled (`Fg `Green) (quote string) in
  let fname = Fieldslib.Field.name in
  let fget = Fieldslib.Field.get in
  let format_config_field fmt f _ _ =
    field ~label ~sep:(make_spaces (fname f)) (fname f) (fget f) fmt
  in
  concat
    [
      parens
        (record
           (List.map
              ~f:(fun fmt -> parens fmt)
              (Fields.Direct.to_list config
                 ~title:(format_config_field value_style)
                 ~description:(format_config_field value_style)
                 ~authors:
                   (format_config_field (parens (list ~sep:sp value_style)))
                 ~language:(format_config_field value_style)
                 ~base_url:(format_config_field value_style)
                 ~build_dir:(format_config_field value_style)
                 ~routes:(format_config_field (Pp.pp_routes config.routes)))));
      flush;
    ]
    formatter config

let dump_config file config =
  let out = Out_channel.create file in
  let str = Fmt.str "%a" pp config in
  Printf.fprintf out "%s" str
