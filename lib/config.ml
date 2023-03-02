open Core

type t = {
  name : string; [@default "Papyrus"]
  description : string; [@default "A sample Papyrus project"]
  authors : string list; [@sexp.list]
  language : string; [@default "en"]
  root_dir : string; [@default ""] [@sexp_drop_default String.equal]
  routes : (string * string) list; [@sexp.list]
}
[@@deriving sexp, show { with_path = false }]

let load_config file = Sexp.load_sexp_conv_exn file t_of_sexp
let default_config = Sexp.of_string "()" |> t_of_sexp

let make_config ~name ~description ~language =
  { default_config with name; description; language }

let dump_config file config =
  let out = Out_channel.create file in
  let str = sexp_of_t config |> Sexp_pretty.sexp_to_string in
  Printf.fprintf out "%s" str
