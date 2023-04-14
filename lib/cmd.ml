open Cmdliner

let verbose_term =
  let info = Arg.info ["v"; "verbose"] ~doc:"Verbose command output" in
  Arg.value (Arg.flag info)

let title_term =
  let info = Arg.info [] ~doc:"The name of your project" ~docv:"NAME" in
  Arg.value (Arg.pos 0 (Arg.some Arg.string) None info)

let description_term =
  let info =
    Arg.info [ "d"; "description" ] ~docv:"DESCRIPTION"
      ~doc:"Description of the project"
  in
  Arg.value (Arg.opt (Arg.some Arg.string) None info)

let language_term =
  let default = "en" in
  let info =
    Arg.info [ "l"; "language" ] ~docv:"LANGUAGE"
      ~doc:"Language of the project"
  in
  Arg.value (Arg.opt Arg.string default info)

let gitignore_term =
  let info =
    Arg.info [ "gitignore" ] ~docv:"GITIGNORE"
      ~doc:"Create a .gitignore in your project"
  in
  Arg.value (Arg.flag info)

let init_term =
  Term.(
    const Init.init_cmd $ title_term $ description_term $ language_term $ gitignore_term)

let init =
  let doc = "Initialise a Papyrus project" in
  let man = [ `S Manpage.s_synopsis; `P "papyrus init [OPTIONS] [NAME]" ] in
  let info = Cmd.info "init" ~man ~doc in
  Cmd.v info init_term


let dev_term = Term.(const Dev.dev_cmd $ const ())

let dev =
  let doc = "Start the dev server" in
  let info = Cmd.info "dev" ~doc in
  Cmd.v info dev_term

let build_term = Term.(const Build.build_cmd $ verbose_term)

let build =
  let doc = "Build a Papyrus project" in
  let info = Cmd.info "build" ~doc in
  Cmd.v info build_term

let cmd =
  let info = Cmd.info "papyrus" in
  Cmd.group info [ init; build; dev ]

let papyrus = Cmd.eval cmd |> exit
