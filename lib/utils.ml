open Core_unix
open Stdio

let cp source dest =
  match Sys_unix.is_file dest with
  | `Yes -> ()
  | _ ->
      let contents = In_channel.read_all source in
      Out_channel.write_all dest ~data:contents
