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

type ident = { stamp: int; name: string; mutable flags: int }
    
type constant =
  | Const_int of int
  | Const_char of char
  | Const_string of string
  | Const_float of string
  | Const_int32 of int32
  | Const_int64 of int64
  | Const_nativeint of nativeint
      
type structured_constant =
  | Const_base of constant
  | Const_pointer of int
  | Const_block of int * structured_constant list
  | Const_float_array of string list
  | Const_immstring of string
      
type reloc_info =
  | Reloc_literal of structured_constant    (* structured constant *)
  | Reloc_getglobal of ident                (* reference to a global *)
  | Reloc_setglobal of ident                (* definition of a global *)
  | Reloc_primitive of string               (* C primitive number *)
      
(* Descriptor for compilation units *)
      
type compilation_unit = {
  cu_name: string;                      (* Name of compilation unit *)
  mutable cu_pos: int;                  (* Absolute position in file *)
  cu_codesize: int;                     (* Size of code block *)
  cu_reloc: (reloc_info * int) list;    (* Relocation information *)
  cu_imports: (string * Digest.t) list; (* Names and CRC of intfs imported *)
  cu_primitives: string list;           (* Primitives declared inside *)
  mutable cu_force_link: bool;          (* Must be linked even if unref'ed *)
  mutable cu_debug: int;                (* Position of debugging info, or 0 *)
  cu_debugsize: int;                    (* Length of debugging info *)
}


(* Debugging events *)

(* abstract types for part of the actual implementation we don't need/want
   to reveal *)
type env_summary
and subst_t
and compilation_env
and types_type_expr

type debug_event = {
  ev_pos: int;                        (* Position in bytecode *)
  ev_module: string;                  (* Name of defining module *)
  ev_loc: location_t;                 (* Location in source file *)
  ev_kind: debug_event_kind;          (* Before/after event *)
  ev_info: debug_event_info;          (* Extra information *)
  ev_typenv: env_summary;             (* Typing environment *)
  ev_typsubst: subst_t;               (* Substitution over types *)
  ev_compenv: compilation_env;        (* Compilation environment *)
  ev_stacksize: int;                  (* Size of stack frame *)
  ev_repr: debug_event_repr }         (* Position of the representative *)

and debug_event_kind =
    Event_before
  | Event_after of types_type_expr
  | Event_pseudo

and debug_event_info =
    Event_function
  | Event_return of int
  | Event_other

and debug_event_repr =
    Event_none
  | Event_parent of int ref
  | Event_child of int ref

and location_t = {
  loc_start: Lexing.position;
  loc_end: Lexing.position;
  loc_ghost: bool;
}

