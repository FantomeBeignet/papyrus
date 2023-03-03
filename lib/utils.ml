open Stdio

let cp source dest =
  match Sys_unix.is_file dest with
  | `Yes -> ()
  | _ ->
      let contents = In_channel.read_all source in
      Out_channel.write_all dest ~data:contents

let chop_prefix ~prefix filename =
  let len_p = String.length prefix and len_f = String.length filename in
  if len_f >= len_p then
    let pre = String.sub filename 0 len_p in
    if pre = prefix then
      Some (String.sub filename (len_p + 1) (len_f - len_p - 1))
    else None
  else None
