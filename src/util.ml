let really_input_string ic len =
  let s = Bytes.create len in
  really_input ic s 0 len;
  (* s is local and does not escape:
    it will never be written again and we can transfer ownership *)
  Bytes.unsafe_to_string s
