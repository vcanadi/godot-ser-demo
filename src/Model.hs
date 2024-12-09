{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Model where

import Data.List (intercalate, intersperse)
import GHC.Generics (Generic (from), Rep)
import Data.Default (Default (def))
import Control.Lens.TH ( makeLenses )
import Data.Map.Strict (toList, Map, elems)
import Data.Godot.Serialize (Serializable (ser), desP)
import qualified Network.Socket as NS
import Network.Socket.Address(SocketAddress(..))
import Data.Word (Word16)
import qualified Data.String.Interpolate as SI
import Godot.Lang.Class (ToDC (..))
import Godot.Lang.Core
import Godot.Lang.Trans
import Foreign (Ptr)
import Unsafe.Coerce (unsafeCoerce)

type PortNumber = Int


toNSPortNumber :: PortNumber -> NS.PortNumber
toNSPortNumber = fromInteger . toInteger

fromNSPortNumber :: NS.PortNumber -> PortNumber
fromNSPortNumber = fromInteger . toInteger

fromNSSockAddr :: NS.SockAddr -> SockAddr
fromNSSockAddr (NS.SockAddrInet p h)  = SockAddrInet (fromNSPortNumber p) (fromIntegral h)
fromNSSockAddr _  = SockAddrDummy

toNSSockAddr :: SockAddr -> NS.SockAddr
toNSSockAddr (SockAddrInet p h)  = NS.SockAddrInet (toNSPortNumber p) (fromIntegral h)
toNSSockAddr _                   = error "Don't use SockAddrDummy"

type HostAddress = Int

data SockAddr
  = SockAddrInet
    { port :: PortNumber      -- sin_port
    , host :: HostAddress     -- sin_addr  (ditto)
    }
  | SockAddrDummy
  deriving (Eq, Ord, Show, Generic)

peekSockAddr ptr = fromNSSockAddr <$> peekSocketAddress (unsafeCoerce ptr :: Ptr NS.SockAddr)
pokeSockAddr p sa = pokeSocketAddress p (toNSSockAddr sa)

instance SocketAddress SockAddr where
  sizeOfSocketAddress = sizeOfSocketAddress . toNSSockAddr
  peekSocketAddress = peekSockAddr
  pokeSocketAddress = pokeSockAddr

instance Serializable SockAddr
instance ToDC SockAddr

-- | State of the game (client info and board coordinates)
type Model = Map SockAddr Loc

data Dir = L | R | U | D deriving (Show, Eq, Generic, Enum, Bounded, Read)

instance Serializable Dir
instance ToDC Dir

-- data Player = Player { playerLoc :: Loc } deriving (Show,Eq, Generic, Serializable)

data Loc = Loc
  { i :: Int
  , j :: Int
  } deriving (Show, Eq, Generic)

instance Serializable Loc

$(makeLenses ''Loc)

instance Default Loc where
  def = Loc 0 0

instance ToDC Loc where
  extraStatVars _ = [ DefVar (VarName "m") (TypPrim PTInt) (Just "10")
                    , DefVar (VarName "n") (TypPrim PTInt) (Just "10")
                    ]
  extraFuncs _ =
    [ func "display" [] (TypPrim PTString)
        [ StmtRaw locDisplayFuncBody ]
    ]

locDisplayFuncBody :: String
locDisplayFuncBody =
  [SI.i|
  var s: String = ""
  for _j in range(m-1,-1,-1):
    for _i in range(n):
      s += ("X" if i == _i and j == _j else " ") + "|"
    s+="\\n"
  return s
  |]

displayModel :: Model -> String
displayModel state  = show state <> concat
  [ concat
    [ displayField i j
    | i <- [0..pred n]] <> "\n"
  | j<- reverse [0..pred m]]
  where
    displayField i j= if Loc i j `notElem` elems state then "_" else "X"

displayLoc :: Loc -> String
displayLoc (Loc i0 j0) = concat
                      $ replicate (m-1-j0) emptyRow
                     <> [currentRow]
                     <> replicate j0 emptyRow
  where
    emptyRow = intersperse '|' $ replicate n ' ' <> "\n"
    currentRow =  intersperse '|' $ replicate i0 ' ' <> "X" <> replicate (n - 1 - i0) ' ' <> "\n"

n = 10
m = 10

move :: Int -> Int -> Loc -> Loc
move di dj (Loc i j ) = Loc ((i + di) `mod` n) ( (j + dj) `mod` m)

moveInDir :: Maybe Dir -> Loc -> Loc
moveInDir (Just L) = move (-1)   0
moveInDir (Just R) = move   1    0
moveInDir (Just U) = move   0    1
moveInDir (Just D) = move   0  (-1)
moveInDir _ = id

readDir :: Char -> Maybe Dir
readDir 'A' = Just L
readDir 'a' = Just L
readDir 'D' = Just R
readDir 'd' = Just R
readDir 'W' = Just U
readDir 'w' = Just U
readDir 'S' = Just D
readDir 's' = Just D
readDir _ = Nothing
