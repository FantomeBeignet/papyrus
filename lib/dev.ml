module C = Cmdliner

let dev () = print_endline "dev"
let dev_term = C.Term.(const dev $ const ())

let dev_command =
  let doc = "Start the dev server" in
  let info = C.Cmd.info "dev" ~doc in
  C.Cmd.v info dev_term
