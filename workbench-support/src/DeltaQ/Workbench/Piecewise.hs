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
  , displayPDF
--   , constructCDF
--   , constructLinearCDF
  , probMass
--  , multiWeightedChoice
  , module WB
  , plotCDFs
  , plotPDFs

  )
where

import DeltaQ.Class()
import PWPs.IRVs (IRV)
import qualified PWPs.IRVs as P

import Graphics.Rendering.Chart.Easy as WB hiding (close)
import IHaskell.Display as WB
import IHaskell.Display.Charts as WB ()

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

displayPDF :: Int -> DeltaQ Double -> [(Double, Double)]
displayPDF  = P.displayPDF

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


plotCDFs :: Int               -- ^ Sample points for graphing
         -> String            -- ^ plot title
         -> [(String, DeltaQ Double)] -- ^ list of named ∆Q's
         -> Renderable ()
plotCDFs n t dqs =
  toRenderable $ do
    layout_title .= t
    layout_x_axis . laxis_title .= "Delay (s)"
    layout_y_axis . laxis_title .= "Probability Mass"
    mapM (\(a,b) -> plot $ line a [genSamples n b]) dqs
   where
     genSamples = displayCDF

plotPDFs :: Int               -- ^ Sample points for graphing
         -> String            -- ^ plot title
         -> [(String, DeltaQ Double)] -- ^ list of named ∆Q's
         -> Renderable ()
plotPDFs n t dqs =
  toRenderable $ do
    layout_title .= t
    layout_x_axis . laxis_title .= "Delay (s)"
    layout_y_axis . laxis_title .= "Probability Mass Density"
    mapM (\(a,b) -> plot $ line a [genSamples n b]) dqs
   where
     genSamples = displayPDF
