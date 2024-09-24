open Core
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
    let pre = String.sub filename ~pos:0 ~len:len_p in
    if String.equal pre prefix then
      Some (String.sub filename ~pos:(len_p + 1) ~len:(len_f - len_p - 1))
    else None
  else None

let get_fields_align fields =
  let rec aux acc = function
    | [] -> acc
    | (elt, _) :: tl when String.length elt > acc -> aux (String.length elt) tl
    | _ :: tl -> aux acc tl
  in
  let max_field_length = aux 0 fields in
  List.map ~f:(fun (elt, _) -> max_field_length - String.length elt) fields

let concat_paths p1 p2 =
  if String.is_empty p1 then p2 else Filename.concat p1 p2
