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

data Person = Person {
  name :: String,
  age :: Int
} deriving (Show, Generic)

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

instance ToJSON Person 
instance FromJSON Person

splitOnTab :: String -> [String]
splitOnTab x = splitOn "\t" x

getIncidents :: FilePath -> IO [Incident]
getIncidents x = do 
  contents <- readFile x
  let rows = map getIncident $ tail ( map splitOnTab (lines contents) )
  return rows

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

getFirstIncident :: FilePath -> IO Incident 
getFirstIncident x = do 
  incidents <- getIncidents x 
  return (incidents !! 0)
  
main :: IO ()
main = do 
  incident <- getFirstIncident "incidents.tsv"
  print (encode incident)

-- index :: ActionM ()
-- index = do 
--   -- fileContents <- getData "incidents.tsv"
--   html "<h2>FP @ UWA</h2>"

-- incidentRoute :: ActionM ()
-- incidentRoute = do 
--   let incident = getFirstIncident "incidents.tsv" 
--   html "<h2>" <> details incident <> "</h2>" 

-- routes :: ScottyM ()
-- routes = do 
--   get "/" index 
--   get "/incidents/" incidentRoute

-- main :: IO () 
-- main = do 
--   putStrLn "server started on port 3000"
--   scotty 3000 routes 

