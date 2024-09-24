(lang dune 3.7)

(name papyrus)

(generate_opam_files true)

(source
 (github FantomeBeignet/papyrus))

(authors "Tom Béné")

(maintainers "Tom Béné")

(license LICENSE)

(documentation https://github.com/FantomeBeignet/papyrus#readme)

(package
 (name papyrus)
 (synopsis "Documentation site generator from markdown")
 (description "Static documentation site generator from markdown files ")
 (depends 
   ocaml 
   dune
   core
   core_unix
   stdio
   cmarkit
   markup
   fmt
   cmdliner
   ppx_let 
   ppx_sexp_conv 
   ppx_deriving
   ppx_string 
   ppx_fields_conv)
 (tags
  (markdown documentation "site generator")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
