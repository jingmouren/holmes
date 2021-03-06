{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE ViewPatterns #-}
module Test.Data.Propagator where

import qualified Control.Monad.Cell.Class as Cell
import Data.Holmes
import qualified Data.Propagator as Prop
import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Prelude hiding (read)
import Test.Control.Monad.Cell.Class (Lestrade, read, scotlandYardSays)
import Test.Data.JoinSemilattice.Defined (defined_int)

hprop_eqR_reflexivity :: Property
hprop_eqR_reflexivity = property do
  x <- forAll defined_int

  let program :: Lestrade h ()
      program = Prop.down (Prop.lift x .== Prop.lift x)
            >>= \o -> Cell.write o (Exactly True)

  if scotlandYardSays program == Nothing
    then x === Conflict
    else success

hprop_eqR_negation :: Property
hprop_eqR_negation = property do
  x <- forAll defined_int
  y <- forAll defined_int

  let this :: Lestrade h ()
      this = Prop.down (Prop.lift x .== Prop.lift y) >>= \o -> Cell.write o (Exactly True)

      that :: Lestrade h ()
      that = Prop.down (Prop.lift x ./= Prop.lift y) >>= \o -> Cell.write o (Exactly False)

  scotlandYardSays this === scotlandYardSays that

hprop_eqR_simple :: Property
hprop_eqR_simple = property do
  (Exactly -> x) <- forAll (Gen.int (Range.linear 0 10))
  (Exactly -> y) <- forAll (Gen.int (Range.linear 0 10))

  let program :: Lestrade h (Defined Bool)
      program = Prop.down (Prop.lift x .== Prop.lift y) >>= read

  scotlandYardSays program === Just (Exactly (x == y))

hprop_eqR_symmetry :: Property
hprop_eqR_symmetry = property do
  x <- forAll defined_int
  y <- forAll defined_int

  let this :: Lestrade h (Defined Bool)
      this = Prop.down (Prop.lift x .== Prop.lift y) >>= read

      that :: Lestrade h (Defined Bool)
      that = Prop.down (Prop.lift y .== Prop.lift x) >>= read

  scotlandYardSays this === scotlandYardSays that

hprop_ordR_negation :: Property
hprop_ordR_negation = property do
  x <- forAll defined_int
  y <- forAll defined_int

  let this :: Lestrade h (Defined Bool)
      this = Prop.down (Prop.lift x .<= Prop.lift y) >>= read

      that :: Lestrade h (Defined Bool)
      that = Prop.down (Prop.lift x .> Prop.lift y) >>= read

  scotlandYardSays this === fmap (fmap not) (scotlandYardSays that)

hprop_ordR_lteR_symmetry :: Property
hprop_ordR_lteR_symmetry = property do
  x <- forAll defined_int
  y <- forAll defined_int

  let this :: Lestrade h (Defined Bool)
      this = Prop.down (Prop.lift x .<= Prop.lift y) >>= read

      that :: Lestrade h (Defined Bool)
      that = Prop.down (Prop.lift y .>= Prop.lift x) >>= read

  scotlandYardSays this === scotlandYardSays that

hprop_ordR_ltR_symmetry :: Property
hprop_ordR_ltR_symmetry = property do
  x <- forAll defined_int
  y <- forAll defined_int

  let this :: Lestrade h (Defined Bool)
      this = Prop.down (Prop.lift x .< Prop.lift y) >>= read

      that :: Lestrade h (Defined Bool)
      that = Prop.down (Prop.lift y .> Prop.lift x) >>= read

  scotlandYardSays this === scotlandYardSays that

hprop_ordR_simple :: Property
hprop_ordR_simple = property do
  (Exactly -> x) <- forAll (Gen.int (Range.linear 0 10))
  (Exactly -> y) <- forAll (Gen.int (Range.linear 0 10))

  let program :: Lestrade h (Defined Bool)
      program = Prop.down (Prop.lift x .<= Prop.lift y) >>= read

  scotlandYardSays program === Just (Exactly (x <= y))
