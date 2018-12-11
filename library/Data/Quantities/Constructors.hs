-- | Defines the common constructors used to build quantities.
module Data.Quantities.Constructors where

import Data.Quantities.Data
import Data.Quantities.DefaultUnits (defaultDefString)
import Data.Quantities.Definitions (readDefinitions)
import Data.Quantities.ExprParser (parseExprQuant)

-- | Default set of definitions that come predefined.
defaultDefinitions :: Either (QuantityError Double) Definitions
defaultDefinitions = readDefinitions defaultDefString

-- $setup
-- >>> import Data.Quantities

-- | Create a Quantity by parsing a string. Uses an 'UndefinedUnitError' for
-- undefined units. Handles arithmetic expressions as well.
--
-- >>> fromString "25 m/s"
-- Right 25.0 meter / second
-- >>> fromString "fakeunit"
-- Left Undefined unit fakeunit
-- >>> fromString "ft + 12in"
-- Right 2.0 foot
--
-- This function also supports unit conversions, by placing \"=>\" in between
-- two valid expressions. This behavior is undefined (and returns a
-- 'ScalingFactorError') if the quantity to be converted to has a magnitude.
--
-- >>> fromString "min => s"
-- Right 60.0 second
-- >>> fromString "2 ft + 6 in => ft"
-- Right 2.5 foot
-- >>> fromString "m => 3 ft"
-- Left Unexpected scaling factor 3.0 foot
--
-- Make sure not to use dimensional quantities in exponents.
--
-- >>> fromString "m ** 2"
-- Right 1.0 meter ** 2
-- >>> fromString "m ** (2s)"
-- Left Parse error: Used non-dimensionless exponent in ( Right 1.0 meter ) ** ( Right 2.0 second )
fromString :: String -> Either (QuantityError Double) (Quantity Double)
fromString s = case defaultDefinitions of
                    (Right d) -> parseExprQuant d s
                    (Left d)  -> Left d


-- | Create quantities with custom definitions.
--
-- >>> let myDefString = defaultDefString ++ "\nmy_unit = 100 s"
-- >>> let (Right d) = readDefinitions myDefString
-- >>> let myFromString = fromString' d
-- >>> myFromString "25 my_unit"
-- Right 25.0 my_unit
fromString' :: Definitions -> String -> Either (QuantityError Double) (Quantity Double)
fromString' = parseExprQuant


-- | Parse units from a string. Equivalent to @fmap units . fromString@
--
-- >>> unitsFromString "N * s"
-- Right newton second
unitsFromString :: String -> Either (QuantityError Double) CompoundUnit
unitsFromString = fmap units . fromString
