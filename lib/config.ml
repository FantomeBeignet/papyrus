open Core

type t = {
  name : string option; [@sexp.option]
  root_dir : string; [@default ""] [@sexp_drop_default String.equal]
  routes : (string * string) list; [@sexp.list]
}
[@@deriving sexp, show]
[@@deriving sexp, show { with_path = false }]

let load_config file = Sexp.load_sexp file |> t_of_sexp
