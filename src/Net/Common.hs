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
import Data.Store
import GHC.Generics (Generic)
import Control.Arrow (ArrowChoice(left))
import Model ( Model, Dir, displayMap, moveInDir )
import Data.Default
import Control.Lens ((%~))
import Data.Maybe (fromJust)
import Data.List (elemIndex)
import Data.Godot.Serialize

srvAddr :: SockAddr
srvAddr = SockAddrInet 5000 (tupleToHostAddress (127,0,0,1))

data CliMsg
  = CLI_JOIN
  | CLI_LEAVE
  | CLI_MOVE Dir
  | CLI_GET_STATE
  deriving (Show, Eq, Read, Generic)

instance Bounded CliMsg where
  minBound = CLI_JOIN
  maxBound = CLI_GET_STATE

instance Enum CliMsg where
  toEnum = (([ CLI_JOIN, CLI_LEAVE] <> (CLI_MOVE <$> [minBound..maxBound]) <>  [CLI_GET_STATE]) !!)
  fromEnum = fromJust . (`elemIndex` ([ CLI_JOIN, CLI_LEAVE] <> (CLI_MOVE <$> [minBound..maxBound]) <>  [CLI_GET_STATE]))

instance Store CliMsg
instance Serializable CliMsg

cliMsgs:: [CliMsg]
cliMsgs = [minBound..maxBound]

data SrvMsg
  = SRV_JOIN
  | SRV_LEAVE
  | SRV_MOVE
  | SRV_INC
  | SRV_GET_STATE State
  deriving (Show, Eq, Generic)

instance Serializable PortNumber where
  ser port = ser @Word16 $ fromIntegral port
  desP = fromIntegral <$> desP @Word16

deriving instance Generic SockAddr
instance Serializable SockAddr

instance Store SockAddr
instance Store SrvMsg
instance Serializable SrvMsg

type State = Map SockAddr Model

decodeMsg :: (Serializable a) => ByteString -> Either String a
decodeMsg = left show . des

encodeMsg :: (Serializable a) => a -> ByteString
encodeMsg = ser

decodeSrvMsg :: (Serializable a) => ByteString -> Either String a
decodeSrvMsg = left show . des

encodeSrvMsg :: (Serializable a) => a -> ByteString
encodeSrvMsg = ser

-- | Main function that updates server state based on client message and returns response
processCliMsg :: SockAddr -> CliMsg -> State -> (SrvMsg, State)
processCliMsg cliAddr CLI_JOIN      state = (SRV_JOIN, insert cliAddr def state)
processCliMsg cliAddr CLI_LEAVE     state = (SRV_LEAVE, delete cliAddr state)
processCliMsg cliAddr CLI_GET_STATE state = (SRV_GET_STATE state , state)
processCliMsg cliAddr (CLI_MOVE d)  state = (SRV_INC, adjust (moveInDir $ Just d) cliAddr state)

-- | Main function that updates client state based on server message and returns response
processSrvMsg :: SockAddr -> SrvMsg -> String
processSrvMsg srvAddr (SRV_GET_STATE state) =  displayMap state
processSrvMsg srvAddr rsp = "Got rsp from srv: " <> show rsp
