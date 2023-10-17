module DeltaQ.Workbench.Piecewise
  ( DeltaQ
  , constructUniform
  , constructDelta
  , perfection
  , bottom
  , (<+>)
--   , probChoice
--   , firstToFinish
--   , lastToFinish
  , displayCDF
  , displayPMF
--   , constructCDF
--   , constructLinearCDF
  , probMass
--  , multiWeightedChoice
  )
where

import DeltaQ.Class()
import PWPs.IRVs (IRV)
import qualified PWPs.IRVs as P

-- temporarily make probability and delay type the same

type DeltaQ  t =  IRV t

constructUniform :: Double -> DeltaQ Double
constructUniform = P.constructUniform

constructDelta :: Double -> DeltaQ Double
constructDelta = P.constructDelta

(<+>) :: DeltaQ Double -> DeltaQ Double -> DeltaQ Double
(<+>) = (P.<+>)

--   , probChoice
--   , firstToFinish
--   , lastToFinish

displayCDF :: Int -> DeltaQ Double -> [(Double, Double)]
displayCDF = P.displayCDF

displayPMF :: Int -> DeltaQ Double -> [(Double, Double)]
displayPMF  = P.displayPDF

--   , constructCDF
--   , constructLinearCDF
--   , probMass

probMass :: DeltaQ Double -> Double
probMass = P.probMass

--  , multiWeightedChoice

perfection :: DeltaQ Double
perfection = constructDelta 0

bottom :: DeltaQ Double
bottom = P.zeroPDF
