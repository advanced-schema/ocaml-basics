module type S = sig
  module Accu: OBMonoid.S
  module Monad: OBMonad.S2
    with type ('ok, 'err) t = ('ok, 'err) result
  module Applicative: OBApplicative.S2
    with type ('ok, 'err) t = ('ok, 'err) result

  type ('ok, 'err) t = ('ok, 'err) result =
    | Ok of 'ok
    | Error of 'err
    [@@deriving sexp]

  include module type of Monad.Core
  include module type of Applicative.Core

  val choose:
    ('ok, 'err Accu.t) t
    -> ('ok, 'err Accu.t) t
    -> ('ok, 'err Accu.t) t

  val traverse: ('a -> ('b, 'err) t) -> 'a list -> ('b list, 'err) t
  val sequence: ('ok, 'err) t list -> ('ok list, 'err) t

  module Infix: sig
    include module type of Monad.Infix
    include module type of Applicative.Infix

    val (<|>):
      ('ok, 'err Accu.t) t
      -> ('ok, 'err Accu.t) t
      -> ('ok, 'err Accu.t) t
  end
end

module Make(Accu: OBMonoid.S): S
  with module Accu = Accu
= struct
  module Accu = Accu

  type ('ok, 'err) t = ('ok, 'err) result =
    | Ok of 'ok
    | Error of 'err
    [@@deriving sexp]

  module Kernel = struct
    type nonrec ('ok, 'err) t = ('ok, 'err) t
    let return x = Ok x

    let bind m f =
      match m with
      | Ok x -> f x
      | Error x -> Error x
  end

  module Monad = OBMonad.Make2(Kernel)
  include Monad.Core

  module Applicative = OBApplicative.Make2(Kernel)
  include Applicative.Core

  let choose lhs rhs =
    match lhs, rhs with
    | Ok _, _ -> lhs
    | _, Ok _ -> rhs
    | Error a, Error b -> Error (Accu.add a b)

  let rec traverse_ f accu l =
    match l with
    | [] -> accu |> List.rev |> return
    | head :: tail ->
      bind (f head) (fun x ->
        traverse_ f (x :: accu) tail)

  let traverse f l = traverse_ f [] l

  let sequence l = traverse (fun x -> x) l

  module Infix = struct
    include Monad.Infix
    include Applicative.Infix
    let (<|>) = choose
  end
end

module ListMonoid = OBMonoid.Make(struct
  type 'a t = 'a list

  let add = List.append
  let zero = []
end)

include Make(ListMonoid)
