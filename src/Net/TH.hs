{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Net.TH where

import Godot.Lang.TH
import Godot.Lang.Class (ToDC)
import Net.Common
import Model

-- Add any addition instances Of ToDC
instance ToDC (Maybe Dir)

$(allToDCInsts)
