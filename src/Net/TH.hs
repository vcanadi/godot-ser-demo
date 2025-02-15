{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Net.TH where

import Godot.Lang.TH
import Godot.Lang.Class ( ToDC, toGDScriptExtra )
import Net.Common
import Model
import Data.Proxy (Proxy(Proxy))
-- import Language.Haskell.TH

-- Add any addition instances Of ToDC

-- | Generate code:
-- newtype AllToDCInsts = [...type level list of all ToDC instances...]
$(qAllToDCInsts)

-- | Generate gd files with runhaskell
main :: IO ()
main = toGDScriptExtra "gd/src/net" (Proxy @AllToDCInsts)

-- | Run during compilation 'toGDScriptExtra "common" (Proxy @AllToDCInsts)' to generate godot file
-- $(runIO $ do putStrLn "START"
--              getCurrentDirectory >>= putStrLn
--              putStrLn "END" >> toGDScriptExtra "/tmp" (Proxy @AllToDCInsts)
--              pure []
--  )
