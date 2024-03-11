{-# LANGUAGE DeriveAnyClass #-}
module Net.Common where

import Net.Utils

import qualified Data.ByteString as B
import qualified Data.Text as T
import Data.Text.Encoding (encodeUtf8)
import Network.Socket (SockAddr(..), tupleToHostAddress, PortNumber)
import Data.ByteString ( ByteString)
import Data.Word (Word8, Word32, Word16)
import Data.Map.Strict (Map, insert, adjust, delete)
import Text.Read (readEither, readMaybe)
import Data.ByteString.Char8(unpack)
import Data.ByteString.UTF8 (fromString)
import GHC.Generics (Generic)
import Control.Arrow (ArrowChoice(left))
import Model ( Loc, Dir(..), displayModel, moveInDir, Model, readDir )
import Data.Default ( Default(def) )
import Control.Lens ((%~))
import Data.Maybe (fromJust)
import Data.List (elemIndex)
import Data.Godot.Serialize ( Serializable(ser, des) )

srvAddr :: SockAddr
srvAddr = SockAddrInet 5000 (tupleToHostAddress (127,0,0,1))

data CliMsg
  = JOIN
  | LEAVE
  | MOVE Dir
  | GET_STATE
  deriving (Show, Eq, Read, Generic, Serializable)

charToCliMsg :: Char -> Either String CliMsg
charToCliMsg '1' = Right JOIN
charToCliMsg '2' = Right LEAVE
charToCliMsg '3' = Right GET_STATE
charToCliMsg c = case readDir c of
                   Nothing -> Left "Invalid CliMsg Char"
                   Just d -> Right $ MOVE d

newtype SrvMsg = PUT_STATE Model
  deriving (Show, Eq, Generic, Serializable)

decodeMsg :: (Serializable a) => ByteString -> Either String a
decodeMsg = left show . des

encodeMsg :: (Serializable a) => a -> ByteString
encodeMsg = ser

-- | Main function that updates server Model based on client message and returns response
processCliMsg :: SockAddr -> CliMsg -> Model -> Model
processCliMsg cliAddr JOIN      md = insert cliAddr def md
processCliMsg cliAddr LEAVE     md = delete cliAddr md
processCliMsg cliAddr GET_STATE md = md
processCliMsg cliAddr (MOVE d)  md = adjust (moveInDir $ Just d) cliAddr md

-- | Main function that updates client Model based on server message and returns response
processSrvMsg :: SockAddr -> SrvMsg -> String
processSrvMsg srvAddr (PUT_STATE md) =  displayModel md
