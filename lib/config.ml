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

let load_config file = Sexp.load_sexp file |> t_of_sexp
