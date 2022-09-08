module Net.Utils where

import qualified Data.ByteString as B
import qualified Data.Text as T
import Data.Text.Encoding (encodeUtf8)
import Network.Socket (SockAddr (SockAddrInet), tupleToHostAddress)
import Data.ByteString ( ByteString)
import Data.Map.Strict (Map, insert, adjust, delete)
import Text.Read (readEither, readMaybe)
import Data.ByteString.Char8(unpack)
import Data.ByteString.UTF8 (fromString)

packStr :: String -> B.ByteString
packStr = encodeUtf8 . T.pack

readEnumSkewed :: forall a. (Bounded a, Enum a) => Int -> String -> Maybe a
readEnumSkewed off s = readMaybe s
         >>= (\i -> if 0 <= (i - off) && (i - off) <= fromEnum @a maxBound then Just $ toEnum (i - off) else Nothing)

clrScr :: IO ()
clrScr = putStr "\ESC[2J"
