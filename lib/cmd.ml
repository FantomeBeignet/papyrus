open Cmdliner

let cmd =
  let info = Cmd.info "papyrus" in
  Cmd.group info [ Init.init_command; Build.build_command; Dev.dev_command ]

let papyrus = Cmd.eval cmd |> exit
