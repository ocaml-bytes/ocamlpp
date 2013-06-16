(*************************************************************************)
(*                                                                       *)
(*                               OCamlPP                                 *)
(*                                                                       *)
(*                            Benoit Vaugon                              *)
(*                                                                       *)
(*    This file is distributed under the terms of the CeCILL license.    *)
(*    See file ../LICENSE-en.                                            *)
(*                                                                       *)
(*************************************************************************)

let error msg =
  Printf.eprintf "Error: %s\n" msg;
  exit 1;
;;

let usage_msg = 
  Printf.sprintf "Usage: %s [ -version ] [ -debug | -no-debug ] \
                  (<file.cmo> | <file.byte>)"
    Sys.argv.(0)
;;

let usage () =
  prerr_endline usage_msg;
  exit 1;
;;

let version () =
  print_endline Config.version;
  exit 0;
;;

let target =
  let target = ref None in
  let rest file =
    if !target <> None then begin
      print_endline "ocamlpp processes only one file at a time";
      usage ();
  end else target := Some file
  in
  Arg.parse [
    "-version", Arg.Unit version, "prints version information";
    "-debug", Arg.Set Config.debug, "shows debug information";
    "-no-debug", Arg.Clear Config.debug, "hides debug information";
  ] rest usage_msg;
  match !target with
    | None ->
      print_endline "no input file given";
      usage ()
    | Some target -> target
;;

begin try
  let ((compunit, _code, _debug) as cmo) = Cmoparser.parse target in
  Cmoprinter.print (Globals.find (Globals.Reloc compunit)) stdout cmo;
with Cmoparser.Not_a_cmo -> begin try
  let ic = open_in_bin Sys.argv.(1) in
  let index = Index.parse ic in Index.print stdout index;
  let prims = Prim.parse ic index in Prim.print stdout prims;
  let data = Data.parse ic index in Data.print stdout data;
  let code = Code.parse ic index in
  let debug = Debug.parse ic index in
  let globnames = Globals.find (Globals.Glob (prims, Array.of_list data)) in
  Code.print globnames debug stdout code;
  close_in ic;
with Index.Not_a_byte ->
  error "not a bytecode executable file nor an OCaml object file"
| Failure msg -> error msg end
| Failure msg -> error msg end
