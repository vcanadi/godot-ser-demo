{-# LANGUAGE TemplateHaskell #-}

module Model where

import Data.List (intercalate, intersperse)
import Data.Store ( Store )
import GHC.Generics (Generic)
import Data.Default (Default (def))
import Control.Lens.TH
import Data.Map.Strict (toList, Map, elems)
import Data.Godot.Serialize (Serializable)

data Dir = L | R | U | D deriving (Show, Eq, Generic, Enum, Bounded, Read)

instance Store Dir
instance Serializable Dir

data Model = Model
  { _mX :: Int
  , _mY :: Int
  } deriving (Show, Eq, Generic)

$(makeLenses ''Model)

instance Serializable Model

instance Default Model where
  def = Model 0 0
instance Store Model

displayMap :: Map a Model -> String
displayMap state  = "\n" <> concat
  [ concat
    [ displayField i j
    | i <- [0..pred n]] <> "\n"
  | j<- reverse [0..pred m]]
  where
    displayField i j= if Model i j `notElem` elems state then "_" else "X"

display :: Model -> String
display (Model i0 j0) = concat
                      $ replicate (m-1-j0) emptyRow
                     <> [currentRow]
                     <> replicate j0 emptyRow
  where
    emptyRow = intersperse '|' $ replicate n ' ' <> "\n"
    currentRow =  intersperse '|' $ replicate i0 ' ' <> "X" <> replicate (n - 1 - i0) ' ' <> "\n"

n = 10
m = 10

move :: Int -> Int -> Model -> Model
move di dj (Model i j) = Model ((i + di) `mod` n) ( (j + dj) `mod` m)

moveInDir :: Maybe Dir -> Model -> Model
moveInDir (Just L) = move (-1)   0
moveInDir (Just R) = move   1    0
moveInDir (Just U) = move   0    1
moveInDir (Just D) = move   0  (-1)
moveInDir _ = id

initModel = Model 2 2

readDir "A" = Just L
readDir "a" = Just L
readDir "D" = Just R
readDir "d" = Just R
readDir "W" = Just U
readDir "w" = Just U
readDir "S" = Just D
readDir "s" = Just D
readDir _ = Nothing

