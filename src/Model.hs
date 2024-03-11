{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveAnyClass #-}

module Model where

import Data.List (intercalate, intersperse)
import GHC.Generics (Generic)
import Data.Default (Default (def))
import Control.Lens.TH ( makeLenses )
import Data.Map.Strict (toList, Map, elems)
import Data.Godot.Serialize (Serializable (ser), desP)
import Network.Socket (PortNumber, SockAddr(..))
import Data.Word (Word16)

instance Serializable PortNumber where
  ser port = ser @Word16 $ fromIntegral port
  desP = fromIntegral <$> desP @Word16

deriving instance Generic SockAddr
instance Serializable SockAddr

-- | State of the game (client info and board coordinates)
type Model = Map SockAddr Loc

data Dir = L | R | U | D deriving (Show, Eq, Generic, Enum, Bounded, Read, Serializable)

data Loc = Loc
  { _mX :: Int
  , _mY :: Int
  } deriving (Show, Eq, Generic, Serializable)

$(makeLenses ''Loc)

instance Default Loc where
  def = Loc 0 0

displayModel :: Model -> String
displayModel state  = "\n" <> concat
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
move di dj (Loc i j) = Loc ((i + di) `mod` n) ( (j + dj) `mod` m)

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
