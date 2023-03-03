open Core
open Core_unix
open Defaults

type t = {
  name : string; [@default defaults.name]
  description : string; [@default defaults.description]
  authors : string list; [@sexp.list]
  language : string; [@default defaults.language]
  root_dir : string; [@default ""] [@sexp_drop_default String.equal]
  build_dir : string; [@default "_papyrus"] [@sexp_drop_default String.equal]
  routes : (string * string) list; [@sexp.list]
}
[@@deriving sexp]

let load_config file = Sexp.load_sexp_conv_exn file t_of_sexp
let default_config = Sexp.of_string "()" |> t_of_sexp

let make_config ?(name = defaults.name) ?(description = defaults.description)
    ?(language = defaults.language) () =
  { default_config with name; description; language }

let dump_config file config =
  let out = Out_channel.create file in
  let str = sexp_of_t config |> Sexp_pretty.sexp_to_string in
  Printf.fprintf out "%s" str

let pp config = sexp_of_t config |> Sexp_pretty.sexp_to_string |> print_endline

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
  match config_file with None -> failwith "No config file found" | Some c -> c
