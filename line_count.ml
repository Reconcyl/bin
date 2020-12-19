(* Keep a running tally of the quantity of each unique line
 * passed through STDIN so far - this can be used to evaluate
 * the quality of a random number generator, for example.
 * Requires an ANSI terminal. *)

let rec inc s ns =
  match ns with
  | [] -> [(s, 1)]
  | (s', n) :: ns' ->
    if s = s'
    then (s', n + 1) :: ns'
    else (s', n) :: inc s ns'

let display ns =
  let ns' = ns |> List.sort
    (fun (_, n1) (_, n2) -> - compare n1 n2) in

  let (_, max) = List.hd ns' in
  let pad_len = 1 + String.length (string_of_int max) in

  print_string "\x1b[H\x1b[J";
  ns' |> List.iter (fun (s, n) ->
    let n = string_of_int n in
    let padding = pad_len - String.length n in
    print_string (String.make padding ' ');
    print_string n;
    print_char ' ';
    print_string s;
    print_newline ())

let rec step ns =
  let s = try Some (read_line ()) with End_of_file -> None in
  match s with
  | None -> ()
  | Some s ->
    let ns' = inc s ns in
    display ns';
    step ns'

let () = step []
