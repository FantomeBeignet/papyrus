open Core
open Core_unix
open Defaults

type t = {
  name : string; [@default defaults.name]
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

let make_config ?(name = defaults.name) ?(description = defaults.description)
    ?(language = defaults.language) () =
  { default_config with name; description; language }

let dump_config file config =
  let out = Out_channel.create file in
  let str = sexp_of_t config |> Sexp_pretty.sexp_to_string in
  Printf.fprintf out "%s" str

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

let pp =
  let open Fmt in
  let label = styled (`Fg `Blue) string in
  let quoted = quote string in
  concat
    [
      parens
        (record
           (List.map
              ~f:(fun fmt -> parens fmt)
              [
                field ~label ~sep:sp "name" (fun c -> c.name) quoted;
                field ~label ~sep:sp "description"
                  (fun c -> c.description)
                  quoted;
                field ~label ~sep:sp "authors"
                  (fun c -> c.authors)
                  (parens (list quoted));
                field ~label ~sep:sp "language" (fun c -> c.language) quoted;
                field ~label ~sep:sp "base_url" (fun c -> c.base_url) quoted;
                field ~label ~sep:sp "build_dir" (fun c -> c.build_dir) quoted;
                field ~label ~sep:sp "routes" (fun c -> c.routes) Pp.pp_routes;
              ]));
      flush;
    ]
