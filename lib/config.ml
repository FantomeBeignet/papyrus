open Core
open Core_unix
open Defaults

module Routes = struct
  open Sexplib

  exception Invalid_route of string

  type single_route =
    | Simple of string * string
    | Nested of string * string * single_route list

  type t = single_route list

  let single_route_of_sexp route =
    let open Sexp in
    let rec aux = function
      | List [ Atom url; Atom file ] -> Simple (url, file)
      | List [ Atom url; Atom file; List rest ] ->
          Nested (url, file, List.map ~f:aux rest)
      | s ->
          let exn =
            Of_sexp_error (Invalid_route "Invalid route configuration", s)
          in
          raise exn
    in
    aux route

  let t_of_sexp routes : t =
    let rec aux acc = function
      | [] -> acc
      | r :: tl -> aux (single_route_of_sexp r :: acc) tl
    in
    match routes with
    | Sexp.Atom _ as a ->
        let exn =
          Of_sexp_error (Invalid_route "Invalid route configuration", a)
        in
        raise exn
    | Sexp.List l -> aux [] l |> List.rev

  let sexp_of_single_route route =
    let rec aux = function
      | Simple (url, file) -> Sexp.List [ Sexp.Atom url; Sexp.Atom file ]
      | Nested (url, file, rest) ->
          Sexp.List (Sexp.Atom url :: Sexp.Atom file :: List.map ~f:aux rest)
    in
    aux route

  let sexp_of_t (routes : t) =
    let rec aux acc = function
      | [] -> acc
      | r :: tl -> aux (sexp_of_single_route r :: acc) tl
    in
    let sexp_list = aux [] routes |> List.rev in
    Sexp.List sexp_list

  let to_map routes =
    let rec aux ~prefix acc = function
      | [] -> acc
      | Simple (v, k) :: tl -> (
          let new_map = Map.add acc ~key:k ~data:(Utils.concat_paths prefix v) in
          match new_map with `Ok n -> aux ~prefix n tl | `Duplicate -> aux ~prefix acc tl)
      | Nested (v, k, rest) :: tl -> (
          let with_nested = aux ~prefix:(Utils.concat_paths v prefix) acc rest in
          let new_map = Map.add with_nested ~key:k ~data:(Utils.concat_paths prefix v) in
          match new_map with `Ok n -> aux ~prefix n tl | `Duplicate -> aux ~prefix acc tl)
    in
    aux ~prefix:"" (Map.empty (module String)) routes

  let pp_single_route route = 
  let open Fmt in
  let quoted = quote string in
  let style_simple_route (route, file) =
    const
      (parens
         (pair ~sep:sp
            (styled (`Fg `Magenta) quoted)
            (styled (`Fg `Green) quoted)))
      (route, file)
  in
  let style_nested_first_route (route, file) =
    const
      (hbox (
         (pair ~sep:sp
            (styled (`Fg `Magenta) quoted)
            (styled (`Fg `Green) quoted))))
      (route, file)
  in
    let rec aux = function
      | Simple (url, file) -> style_simple_route (url, file) 
      | Nested (url, file, rest) -> 
          let rest_style = List.map ~f:aux rest |> record |> parens in
          let base_style = style_nested_first_route (url, file) in
          record [ base_style; rest_style ] |> parens
    in aux route

  let pp (routes: t) = 
    let open Fmt in
    List.map ~f:pp_single_route routes |> record |> parens
end

type t = {
  title : string; [@default defaults.title]
  description : string; [@default defaults.description]
  authors : string list; [@sexp.list]
  language : string; [@default defaults.language]
  base_url : string; [@default ""] [@sexp_drop_default String.equal]
  build_dir : string; [@default "_papyrus"] [@sexp_drop_default String.equal]
  routes : Routes.t [@default []];
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
                 ~routes:(format_config_field (Routes.pp config.routes)))));
      flush;
    ]
    formatter config

let dump_config file config =
  let out = Out_channel.create file in
  let str = Fmt.str "%a" pp config in
  Printf.fprintf out "%s" str
