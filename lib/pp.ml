open Fmt

let pp_routes =
  parens
    (vbox
       (list ~sep:cut
          (parens (pair ~sep:sp (styled (`Fg `Magenta) string) string))))

let pp_config =
  let label = styled (`Fg `Blue) string in
  let quoted = quote string in
  parens
    (record
       (List.map
          (fun fmt -> parens fmt)
          [
            field ~label ~sep:sp "name" (fun (t : Config.t) -> t.name) quoted;
            field ~label ~sep:sp "description"
              (fun (t : Config.t) -> t.description)
              quoted;
            field ~label ~sep:sp "authors"
              (fun (t : Config.t) -> t.authors)
              (parens (list quoted));
            field ~label ~sep:sp "language"
              (fun (t : Config.t) -> t.language)
              quoted;
            field ~label ~sep:sp "base_url"
              (fun (t : Config.t) -> t.base_url)
              quoted;
            field ~label ~sep:sp "build_dir"
              (fun (t : Config.t) -> t.build_dir)
              quoted;
            field ~label ~sep:sp "routes"
              (fun (t : Config.t) -> t.routes)
              pp_routes;
          ]))
