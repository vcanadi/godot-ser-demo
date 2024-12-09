{-# LANGUAGE QuasiQuotes #-}

module Net.Common where

import Net.Utils
import qualified Data.ByteString as B
import qualified Data.Text as T
import Data.Text.Encoding (encodeUtf8)
import Data.ByteString ( ByteString)
import Data.Word (Word8, Word32, Word16)
import Data.Map.Strict (Map, insert, adjust, delete)
import Text.Read (readEither, readMaybe)
import Data.ByteString.Char8(unpack)
import Data.ByteString.UTF8 (fromString)
import GHC.Generics (Generic)
import Control.Arrow (ArrowChoice(left))
import Model ( Loc, Dir(..), displayModel, moveInDir, Model, readDir, SockAddr (..), HostAddress, fromNSSockAddr )
import Data.Default ( Default(def) )
import Control.Lens ((%~))
import Data.Maybe (fromJust)
import Data.List (elemIndex)
import Data.Godot.Serialize ( Serializable(ser, des) )
import qualified Data.String.Interpolate as SI
import Godot.Lang.Class (ToDC (..))
import Godot.Lang.Core
import Data.Bits (Bits(shiftL), (.|.))
import qualified Network.Socket as NS

srvAddr :: SockAddr
srvAddr = fromNSSockAddr $ NS.SockAddrInet 5000 (NS.tupleToHostAddress (127,0,0,1))

data CliMsg
  = JOIN
  | LEAVE
  | MOVE Dir
  | GET_STATE
  deriving (Show, Eq, Read, Generic)

instance Serializable CliMsg
instance ToDC CliMsg

charToCliMsg :: Char -> Either String CliMsg
charToCliMsg '1' = Right JOIN
charToCliMsg '2' = Right LEAVE
charToCliMsg '3' = Right GET_STATE
charToCliMsg c = case readDir c of
                   Nothing -> Left "Invalid CliMsg Char"
                   Just d -> Right $ MOVE d

newtype SrvMsg = PUT_STATE { model :: Model }
  deriving (Show, Eq, Generic)

instance Serializable SrvMsg

instance ToDC SrvMsg where
  extraFuncs _ =
    [ func "display" [] (TypPrim PTString)
        [ StmtRaw srvMsgDisplayFuncBody ]
    ]

srvMsgDisplayFuncBody :: String
srvMsgDisplayFuncBody =
  [SI.i|
  var s: String = ""
  for _j in range(Loc.m-1,-1,-1):
    for _i in range(Loc.n):
      s += ("X" if model.any(func(ci): return ci.snd.i == _i and ci.snd.j == _j) else " ") + "|"
    s+="\\n"
  return s
  |]

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
