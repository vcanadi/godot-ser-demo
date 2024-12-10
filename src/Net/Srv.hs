{-# LANGUAGE PatternSynonyms #-}

module Net.Srv where

import Net.Common
import Net.Utils
import Net.Logger
import Model(displayModel, Model (Model), fromNSSockAddr, toNSSockAddr, _modelPlayers)

import Network.Socket(Socket, socket, Family, pattern AF_INET, pattern Datagram, defaultProtocol)
import Network.Socket.Address( bind)
import Network.Socket.ByteString
import Control.Monad (forever, forM_)
import Data.Map.Strict (Map, insert, updateAt, adjust, toList)
import Text.Pretty.Simple
import Data.ByteString.Char8 (unpack)

main :: IO ()
main = do
  sock <- socket AF_INET Datagram defaultProtocol
  print srvAddr
  bind sock srvAddr
  listenToClients sock (Model mempty 0)

-- | For a given socket and a current client list,
-- listen to client messages and update state accordingly
-- Update(send a message) to clients when needed
listenToClients :: Socket -> Model -> IO ()
listenToClients sock = f
  where
    f model = do
      logRecv "Listening..."
      (cliMsgRaw, cliAddr) <- recvFrom sock 1024
      -- clrScr
      logMsg cliAddr cliMsgRaw
      case decodeMsg cliMsgRaw of
        Left err -> logRecv  (show err)
        Right cliMsg -> do
          print $ "cliMgs:" <> show cliMsg
          let newModel = processCliMsg (fromNSSockAddr cliAddr) cliMsg  model
          logRecv  "Current state:"
          logMsg srvAddr $ encodeMsg $ PUT_STATE newModel
          putStrLn $ displayModel newModel
          forM_ (toList $ _modelPlayers newModel) $ \(cl,_) ->
            sendTo sock (encodeMsg $ PUT_STATE newModel) (toNSSockAddr cl)
          f newModel
