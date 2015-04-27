{-|
Following the convention from "Data.Text.Lazy", this module is intended to be
imported @qualified@. For example:

> import qualified Test.SmallCheck.Series.Text.Lazy as L.Series
-}
module Test.SmallCheck.Series.Text.Lazy
  (
  -- * Replication
    aaa
  , zzz
  , replicated
  -- * Enumeration
  , ascii
  , alpha
  , enumerated
  -- * Printing
  , jack
  -- * Extra Unicode planes
  , nonBmp
  ) where

import Prelude hiding (replicate)
import Control.Applicative ((<$>))
import Data.Text.Lazy (Text, pack, singleton, replicate)
import Test.SmallCheck.Series

-- | Create a 'Data.Text.Lazy.Text' 'Series' growing with an extra 'a' 'Char'.
--
-- >>> list 4 aaa
-- ["","a","aa","aaa","aaaa"]
--
-- Use this when you don't care about the 'Char's inside 'Data.Text.Lazy.Text'.
aaa :: Series m Text
aaa = replicated 'a'

-- | Create a 'Data.Text.Lazy.Text' 'Series' growing with an extra @NUL@ 'Char'.
--
-- >>> list 4 zzz
-- ["","\NUL","\NUL\NUL","\NUL\NUL\NUL","\NUL\NUL\NUL\NUL"]
zzz :: Series m Text
zzz = replicated '\0'

-- | Create a 'Data.Text.Lazy.Text' 'Series' growing with an extra custom 'Char'.
--
-- >>> list 4 $ replicated '☃'
-- ["","\9731","\9731\9731","\9731\9731\9731","\9731\9731\9731\9731"]
replicated :: Char -> Series m Text
replicated c = generate $ \d -> (`rep` singleton c) <$> [0..d]
  where
    rep = replicate . fromIntegral

-- | Create a 'Data.Text.Lazy.Text' 'Series' growing with the alphabet.
--
-- >>> list 4 alpha
-- ["","a","ab","abc","abcd"]
alpha :: Series m Text
alpha = enumerated ['a'..'z']

-- | Create a 'Data.Text.Lazy.Text' 'Series' growing with @ASCII@ 'Char's set.
--
-- >>> list 4 ascii
-- ["","\NUL","\NUL\SOH","\NUL\SOH\STX","\NUL\SOH\STX\ETX"]
ascii :: Series m Text
ascii = enumerated ['\0'..'\255']

-- | Create a 'Data.Text.Lazy.Text' 'Series' growing with the given 'Char' set.
--
-- >>> list 4 $ enumerated "abc"
-- ["","a","ab","abc","abc"]
enumerated :: String -> Series m Text
enumerated cs = generate $ \d -> (\n -> pack $ take n cs) <$> [0..d]

-- | Create a 'Data.Text.Lazy.Text' 'Series' with a dummy sentence. This can
--   be used when you want to print a 'Series' to the screen.
--
-- >>> let s = list 20 jack
-- >>> take 3 s
-- ["","All","All work"]
-- >>> s !! 10
-- "All work and no play makes Jack a dull boy"
jack :: Series m Text
jack = generate $ \d ->
    (\n -> pack . unwords . take n . words $ sentence) <$> [0..d]
  where
    sentence = "All work and no play makes Jack a dull boy"

-- | Create a 'Data.Text.Lazy.Text' 'Series' with the first character of each
--   <https://en.wikipedia.org/wiki/Plane_(Unicode) Unicode plane>.
--
-- >>> list 3 nonBmp
-- ["","\NUL","\NUL\65536","\NUL\65536\131072"]
--
-- Notice that this covers the 16 unicode planes.
--
-- >>> last (list 16 nonBmp) == last (list 17 nonBmp)
-- True
nonBmp :: Series m Text
nonBmp = enumerated ['\0','\x10000'..'\xF0000']
