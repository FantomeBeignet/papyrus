open Fmt

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
