module DeltaQ.Workbench.Common
  ( module WB
  , plotCDFs
  , plotPMFs
  )
where
import Graphics.Rendering.Chart.Easy as WB hiding (close)
import IHaskell.Display as WB
import IHaskell.Display.Charts as WB ()

import DeltaQ.Workbench.Piecewise (DeltaQ, displayCDF, displayPMF)

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

plotPMFs :: Int               -- ^ Sample points for graphing
         -> String            -- ^ plot title
         -> [(String, DeltaQ Double)] -- ^ list of named ∆Q's
         -> Renderable ()
plotPMFs n t dqs =
  toRenderable $ do
    layout_title .= t
    layout_x_axis . laxis_title .= "Delay (s)"
    layout_y_axis . laxis_title .= "Probability Mass Density"
    mapM (\(a,b) -> plot $ line a [genSamples n b]) dqs
   where
     genSamples = displayPMF
