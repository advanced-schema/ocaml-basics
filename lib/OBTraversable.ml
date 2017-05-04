module type S1 = sig
  type 'a t
  val traverse: ('a -> 'b t) -> 'a list -> 'b list t
end

module type S2 = sig
  type ('a, 'b) t
  val traverse: ('a -> ('b, 'c) t) -> 'a list -> ('b list, 'c) t
end

let rec traverse bind return f accu l =
  match l with
  | [] -> accu |> List.rev |> return
  | head :: tail ->
    bind (f head) (fun x ->
      traverse bind return f (x :: accu) tail)

let traverse bind return f l = traverse bind return f [] l

module Make1(Monad: OBMonad.S1): S1
  with type 'a t := 'a Monad.t
= struct
  let traverse f l = traverse Monad.bind Monad.return f l
end

module Make2(Monad: OBMonad.S2): S2
  with type ('a, 'b) t := ('a, 'b) Monad.t
= struct
  let traverse f l = traverse Monad.bind Monad.return f l
end
