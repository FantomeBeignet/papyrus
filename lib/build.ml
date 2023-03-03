module Ic = Stdio.In_channel
module Oc = Stdio.Out_channel

let build_file from _to =
  let doc = Omd.of_string (Ic.read_all from) in
  let html = Omd.to_html doc in
  Oc.write_all _to ~data:html

let build_command () =
  let config = Config.find_config () in
  print_endline "Starting build with following config:";
  Config.pp config
