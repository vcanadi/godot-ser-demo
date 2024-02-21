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
  = JOIN
  | LEAVE
  | MOVE Dir
  | GET_STATE
  deriving (Show, Eq, Read, Generic)

instance Bounded CliMsg where
  minBound = JOIN
  maxBound = GET_STATE

instance Enum CliMsg where
  toEnum = (([ JOIN, LEAVE] <> (MOVE <$> [minBound..maxBound]) <>  [GET_STATE]) !!)
  fromEnum = fromJust . (`elemIndex` ([ JOIN, LEAVE] <> (MOVE <$> [minBound..maxBound]) <>  [GET_STATE]))

instance Store CliMsg
instance Serializable CliMsg

cliMsgs:: [CliMsg]
cliMsgs = [minBound..maxBound]

newtype SrvMsg = PUT_STATE State
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
processCliMsg :: SockAddr -> CliMsg -> State -> State
processCliMsg cliAddr JOIN      state = insert cliAddr def state
processCliMsg cliAddr LEAVE     state = delete cliAddr state
processCliMsg cliAddr GET_STATE state = state
processCliMsg cliAddr (MOVE d)  state = adjust (moveInDir $ Just d) cliAddr state

-- | Main function that updates client state based on server message and returns response
processSrvMsg :: SockAddr -> SrvMsg -> String
processSrvMsg srvAddr (PUT_STATE state) =  displayMap state
