open Fmt

let pp_routes routes : (string * string) list t =
  let max_field_length =
    let rec aux acc = function
      | [] -> acc
      | (elt, _) :: tl when String.length elt > acc ->
          aux (String.length elt) tl
      | _ :: tl -> aux acc tl
    in
    aux 0 routes
  in
  let make_spaces route_name =
    sps (max_field_length - String.length route_name + 1)
  in
  let quoted = quote string in
  let style_route (route, file) =
    const
      (parens
         (pair ~sep:(make_spaces route)
            (styled (`Fg `Magenta) quoted)
            (styled (`Fg `Green) quoted)))
      (route, file)
  in
  parens (record (List.map (fun route -> style_route route) routes))

let pp_build_step =
  set_style_renderer stdout `Ansi_tty;
  concat
    [
      const (styled `Bold (styled (`Fg `Blue) string)) "::";
      sp;
      styled `Bold string;
      flush;
    ]

let pp_error =
  set_style_renderer stdout `Ansi_tty;
  concat
    [
      const (styled `Bold (styled (`Fg `Red) string)) "✘";
      sp;
      styled `Bold string;
      flush;
    ]

let pp_success =
  set_style_renderer stdout `Ansi_tty;
  concat
    [
      const (styled `Bold (styled (`Fg `Green) string)) "✔";
      sp;
      styled `Bold string;
      flush;
    ]

let pp_info =
  set_style_renderer stdout `Ansi_tty;
  concat
    [
      const (styled `Bold (styled (`Fg `Magenta) string)) "Info:";
      sp;
      styled `Bold string;
      flush;
    ]
