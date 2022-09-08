module Net.Srv where

import Net.Common
import Net.Utils
import Net.Logger
import Model(displayMap)

import Network.Socket
import Network.Socket.ByteString
import Control.Monad (forever, forM_)
import Data.Map.Strict (Map, insert, updateAt, adjust, toList)
import Text.Pretty.Simple
import Data.ByteString.Char8 (unpack)

main :: IO ()
main = do
  clrScr
  sock <- socket AF_INET Datagram defaultProtocol
  bind sock srvAddr
  listenToClients sock mempty

-- | For a given socket and a current client list,
-- listen to client messages and update state accordingly
-- Update(send a message) to clients when needed
listenToClients :: Socket -> State -> IO ()
listenToClients sock = f
  where
    f clients = do
      logRecv "Listening..."
      (cliMsgRaw, cliAddr) <- recvFrom sock 1024
      clrScr
      logMsg cliAddr cliMsgRaw
      case decodeMsg cliMsgRaw of
        Left err -> logRecv  (show err)
        Right cliMsg -> do
          let (msg, newClients) = processCliMsg cliAddr cliMsg  clients
          logRecv  "Current State:"
          logMsg srvAddr $ encodeMsg $ SRV_GET_STATE newClients
          putStrLn $ displayMap newClients
          -- lPutStrLn $ "Will respond with: " <> show msg
          forM_ (toList newClients) $ \(cl,_) ->
            sendTo sock (encodeMsg $ SRV_GET_STATE newClients) cl
          f newClients
