module Result = OBResult

include Map.Make(String)

let find_exn = find

let find key map =
  try
    Some (find_exn key map)
  with Not_found -> None

let find_or key substitute map =
  try
    find_exn key map
  with Not_found -> substitute

let has key value map =
  let open OBOption.Infix in
  find key map >>= fun x ->
  if x = value then
    Some ()
  else
    None

let traverse
  (type a)
  (type b)
  (type err)
  (f: key -> a -> (b, err) Result.t)
  (map: a t)
  : (b t, err) Result.t
=
  let exception Exception of err in
  try
    Ok (fold (fun key value accu ->
      match f key value with
      | Error x -> raise (Exception x)
      | Ok value' -> add key value' accu) map empty)
  with Exception x -> Error x
