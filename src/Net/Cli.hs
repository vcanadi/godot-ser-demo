{-# LANGUAGE LambdaCase #-}
module Net.Cli where

import Net.Common
    ( CliMsg, srvAddr, decodeMsg, encodeMsg, processSrvMsg, charToCliMsg )
import Net.Utils ( readEnumSkewed )
import Net.Logger ( logMsg, logRecv, logSend )

-- client.hs
import GHC.IO.Handle (hFlush)
import Network.Socket.ByteString
    ( sendAllTo, sendAll, recv, sendAll, sendTo, recvFrom )
import qualified Data.Text.Encoding as T
import qualified Data.Text as T
import Network.Socket.ByteString.Lazy()
import qualified Control.Exception as E
import qualified Data.ByteString.Char8 as C
import Network.Socket
    ( socket,
      defaultProtocol,
      Family(AF_INET),
      Socket,
      SocketType(Datagram) )
import Control.Concurrent (threadDelay, forkIO)
import System.IO ( hSetBuffering, stdin, BufferMode(NoBuffering) )
import System.Environment (getArgs)
import Control.Lens.At(ix)
import Text.Read(readMaybe)
import Data.ByteString.Char8(unpack)
import Control.Monad(forever, void)
import Control.Arrow ((>>>))


main :: IO ()
main = do
  hSetBuffering stdin NoBuffering
  -- clrScr
  sock <- socket AF_INET Datagram defaultProtocol
  void $ forkIO $ sendThread sock
  recvThread sock

-- | Sending only thread. Contains logic that on some events sends a message to server
sendThread :: Socket -> IO ()
sendThread sock =
  forever $ do
    logSend "Select message to send (1 - JOIN, 2 - LEAVE, 3 - GET_STATE, WASD - move):"
    (getChar >>=) $ charToCliMsg >>> \case
      Left err -> logSend err
      Right cliMsg -> do
        bytesSent <- sendTo sock (encodeMsg cliMsg) srvAddr
        logSend $ "Send nbr of bytes: " <> show bytesSent

-- | Recieving and sending thread. Listens for an incoming messages and
-- applies appropriate logic. It also has ability to send a message
recvThread :: Socket -> IO ()
recvThread sock =
  forever $ do
    logRecv "Listening..."
    (srvMsgRaw, srvAddr) <- recvFrom sock 1024
    logMsg srvAddr srvMsgRaw
    case decodeMsg srvMsgRaw of
      Left err -> logRecv (show err)
      Right srvMsg -> do
        let msg = processSrvMsg srvAddr srvMsg
        putStrLn msg
