module Net.Logger where

import qualified Data.ByteString as BS
import Text.Pretty.Simple
import Data.Text.Lazy (unpack)

showLog :: Bool
showLog = True


logSend :: String -> IO ()
logSend = log' "[Send]"

logRecv :: String -> IO ()
logRecv = log' "[Recv]"

log' :: String -> String -> IO ()
log' prefix = if showLog then putStrLn else const (return ())

logMsg :: Show a => a -> BS.ByteString -> IO ()
logMsg addr msgRaw  = logRecv $ unpack $ pShow (addr, fmap show $ chunks 4 $ BS.unpack msgRaw)

chunks :: Int -> [a] -> [[a]]
chunks _ [] = []
chunks n xs =
    let (ys, zs) = splitAt n xs
    in  ys : chunks n zs
