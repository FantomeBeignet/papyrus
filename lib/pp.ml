open Fmt

let pp_routes =
  parens
    (vbox
       (list ~sep:cut
          (parens (pair ~sep:sp (styled (`Fg `Magenta) string) string))))

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
      const (styled `Bold (styled (`Fg `Red) string)) "✘ ";
      sp;
      styled `Bold string;
      flush;
    ]
