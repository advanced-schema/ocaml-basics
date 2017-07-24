# Ocaml Basics

## v0.4.0

* Make Deferred, Option and Result foldable (`b617fd5`, `a7cc20d`, `86b7e6e`)
* Add an OBFoldable module (also accessible through Basics.Foldable
  (`0241e19`, `c225293`)

## v0.3.0

* `9a31703` Implement Map.traverse and Map.traverse'
* `b70bfe0` Implement an alternative Map.traverse
* `2f1df99` Add a get_ok function to results
* `5ac5e52` Fix versions of some opam deps

## v0.2.0

* create a Traversable module to easily add the traverse function to any monad
* create a Deferred module
* Option and Result now use the Traversable module instead of rewriting the
  the traverse function
* add an opam file
* uppercase files' names

## v0.1.0

First release. It contains:

* interfaces and helpers for the monoid, applicative and monad absractions
* Result, Option and Map modules that implement these interfaces
