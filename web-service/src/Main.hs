{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

import Data.Aeson (FromJSON, ToJSON, encode)
import Data.Aeson.Text (encodeToLazyText)
import GHC.Generics
import Web.Scotty
import Data.List.Split
import Data.List
import Data.Char
import Data.Monoid((<>))
import System.IO (readFile, writeFile, appendFile)
import System.IO.Unsafe

-- data type 

data Incident = Incident {
  year :: Int,
  dead :: String,
  date :: String,
  injured :: String,
  incident_type :: String,
  location :: String,
  details :: String,
  perpetrator :: String
} deriving (Show, Generic)

instance ToJSON Incident
instance FromJSON Incident

-- get incidents from file

getLines :: String
getLines = unsafePerformIO $ readFile "incidents.tsv"

getRows :: String -> [String]
getRows x = lines x

getData :: [[String]]
getData = map (splitOn "\t") (getRows (getLines))

getIncidents :: [Incident]
getIncidents = map getIncident (tail getData)

getIncident :: [String] -> Incident
getIncident x =
  Incident {
    year=year,
    dead=dead,
    date=date,
    injured=injured,
    incident_type=incident_type,
    location=location,
    details=details,
    perpetrator=perpetrator
  }
  where
    year = read ( x !! 0 ) :: Int
    dead = x !! 4
    date = x !! 1
    injured = x !! 3
    incident_type = x !! 2
    location = x !! 5
    details = x !! 6
    perpetrator = x !! 7

-- routes and actions

index :: ActionM ()
index = do
  html ("<h2>FP UWA Project One</h2>")

incidentRoute :: ActionM ()
incidentRoute = do
  let incidents = getIncidents
  json (take 10 incidents)
--
yearRoute :: ActionM ()
yearRoute = do
  yr <- param "year"
  let incidents = getIncidents
  json $ take 10 $ getIncidentsInYear yr incidents

typeRoute :: ActionM ()
typeRoute = do
  tp <- param "type"
  let incidents = getIncidents
  json $ take 10 $ getIncidentsOfType tp incidents

perpetratorRoute :: ActionM ()
perpetratorRoute = do
  perp <- param "perpetrator"
  let incidents = getIncidents
  json $ take 10 $ getIncidentsByPerpetrator perp incidents

locationRoute :: ActionM ()
locationRoute = do
  loc <- param "location"
  let incidents = getIncidents
  json $ take 10 $ getIncidentsAtLocation loc incidents

routes :: ScottyM ()
routes = do
  get "/" index
  get "/incidents/" incidentRoute
  get "/year/:year" yearRoute
  get "/type/:type" typeRoute
  get "/perpetrator/:perpetrator" perpetratorRoute
  get "/location/:location" locationRoute

main :: IO ()
main = do
  putStrLn "server started on port 3000"
  scotty 3000 routes

-- retreival functions

toLowerCase :: String -> String
toLowerCase x = map toLower x

inYear :: Int -> Incident -> Bool
inYear yr x = (==) (year x) yr

getIncidentsInYear :: Int -> [Incident] -> [Incident]
getIncidentsInYear y i = filter (inYear y) i

isOfType :: String -> Incident -> Bool
isOfType tp x = isInfixOf (toLowerCase tp) (toLowerCase (incident_type x))

getIncidentsOfType :: String -> [Incident] -> [Incident]
getIncidentsOfType t i = filter (isOfType t) i

byPerpetrator :: String -> Incident -> Bool
byPerpetrator p x = isInfixOf (toLowerCase p) (toLowerCase (perpetrator x))

getIncidentsByPerpetrator :: String -> [Incident] -> [Incident]
getIncidentsByPerpetrator p i = filter (byPerpetrator p) i

atLocation :: String -> Incident -> Bool
atLocation l x = isInfixOf (toLowerCase l) (toLowerCase (location x))

getIncidentsAtLocation :: String -> [Incident] -> [Incident]
getIncidentsAtLocation l i = filter (atLocation l) i

hasDetail :: String -> Incident -> Bool
hasDetail d x = isInfixOf (toLowerCase d) (toLowerCase (details x))

getIncidentsWithDetail :: String -> [Incident] -> [Incident]
getIncidentsWithDetail d i = filter (hasDetail d) i
