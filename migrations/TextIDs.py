import utils
import os.path
import re

GlobalTextIdFilename = "../scripts/globals/TextIDs.lua"
TextIdFileVersionString        = "-- Do not edit this line. Must be first line in file to avoid re-migration. Auto generated TextIDs.lua version 1"
#TextIdFileVersionStringEscaped = "\\-\\- Auto generated TextIDs\\.lua version (.*)"
TextIdFileVersionStringEscaped = "\\-\\- Do not edit this line\\. Must be first line in file to avoid re\\-migration\\. Auto generated TextIDs\\.lua version (.*)"

def log_messages(curs):
    for msg in curs.messages:
            print(msg[1])

def migration_name():
    return "Converting TextIDs to global table"

def check_preconditions(cur):
    cur.execute("SELECT zoneid,name FROM zone_settings LIMIT 1;")

    if not cur.fetchone():
        raise Exception("zone_settings table does not exist. Where are the zone ids at?")

def needs_to_run(cur):
    ret = True
    if (not os.path.isfile(GlobalTextIdFilename)):
        return True
    else:
        f = open(GlobalTextIdFilename, "r");
        line = f.readline()
        m = re.search(TextIdFileVersionStringEscaped, line)
        if m:
            try:
                ver = int(m.group(1))
            except ValueError:
                ver = 0
            if ver >= 1:
                ret = False
        f.close()
        return ret;
    
def migrate(cur, db):
    spellLimit = 1024
    cur.execute("SELECT zoneid,name FROM zone_settings;")
    rows = cur.fetchall()
    
    zoneNameToId = {}
    zoneIdToName = {}
    zoneVars = {}
    varRefs = {}
    unfoundFiles = []
    
    # Scrape all zone files (that have ids in the database) for variables
    for row in rows:
        zoneId = int(row[0])
        zoneName = row[1]
        zoneIdToName[zoneId] = zoneName
        zoneNameToId[zoneName] = zoneId
        idfile = "../scripts/zones/%s/TextIDs.lua" % zoneName
        if (os.path.isfile(idfile)):
            f = open(idfile, "r")
            zoneVars[zoneId] = {}
            matchCount = 0
            for line in f:
                match = re.search("\s*([A-Za-z0-9_]*)\s*=\s*([0-9]*);", line)
                if (match):
                    matchCount += 1
                    zoneVars[zoneId][match.group(1)] = match.group(2)
        else:
            unfoundFiles.append(idfile)

            
    # Scan for duplicate names with the same value and consolidate into a common dict
    replacements = {}
    uniques = {}
    handledVarValPairs = []
    zoneIDs = list(zoneVars.keys())
    # Iterate over all zone IDs...
    L = len(zoneIDs)
    while (L > 1):
        currentZoneID = zoneIDs[0]
        # ... and variable names in those zones...
        for varName in zoneVars[currentZoneID].keys():
            thisZoneVal = zoneVars[currentZoneID][varName]
            if ((varName, thisZoneVal) in handledVarValPairs):
                continue
            i = 1
            matchedZoneIDs = []
            # ... and go over all the other zones ...
            while (i < L):
                compZoneID = zoneIDs[i]
                if (varName in zoneVars[compZoneID].keys()):
                    thatZoneVal = zoneVars[compZoneID][varName]
                    # ... and if the values for the same variable between two zones match, ...
                    if (thisZoneVal == thatZoneVal):
                        # ...remember that.
                        matchedZoneIDs.append(compZoneID)
                i += 1
            if (matchedZoneIDs):
                matchedZoneIDs.append(currentZoneID) # The logic above doesn't (and shouldn't, because it's finding a match between two or more) take the current zone it's iterating over into account, so this.
                repName = varName + "_1"
                n = 2
                # Synthesize a name for the common value that we'll use in the common table.
                while (repName in replacements.keys()):
                    repName = varName + "_" + str(n)
                    n += 1
                # Stores all the relevant information for replacements for use in the output.
                replacements[repName] = {"zones" : matchedZoneIDs, "val" : thisZoneVal, "targetVar" : varName}
            else:
                # Keeps track of which zones have unique values for variables, for the sake of documentation in the common table.
                if (currentZoneID not in uniques.keys()):
                    uniques[currentZoneID] = []
                uniques[currentZoneID].append(varName)
            handledVarValPairs.append((varName, thisZoneVal))
        zoneIDs.pop(0)
        L -= 1
 
    # OUTPUT
    out = open(GlobalTextIdFilename, "w")
    out.write(TextIdFileVersionString + "\n\n")
    for missingFile in unfoundFiles:
        out.write("-- Could not open %s\n" % missingFile)
    if unfoundFiles:
        print("    Warning: %d zones in the database did not have a TextID.lua in the file system." % len(unfoundFiles))
        print("             See %s for a list of files/areas which were skipped." % GlobalTextIdFilename)

    # Generate a module-local table (with a short name) to map IDs which are shared in common among multiple zones
    out.write("\n\nlocal cm = \n{")
    curVar = ""
    prevVar = ""
    repKeys = sorted(replacements.keys())
    L = len(repKeys)
    i = 0
    while (i < L):
        repName = repKeys[i]
        curVar = "_".join(repName.split("_")[:-1])
        if ((curVar != prevVar) and (prevVar != "")):
            zoneIdNamePairs = []
            for zid in uniques.keys():
                if (prevVar in uniques[zid]):
                    zoneIdNamePairs.append("%d:%s" % (zid, zoneIdToName[zid]))
            if zoneIdNamePairs:
                out.write("\n        -- %s is unique in %d zones. %s" % (prevVar, len(zoneIdNamePairs), ", ".join(zoneIdNamePairs)))

        zoneIdNamePairs = []
        for zid in replacements[repName]["zones"]:
            zoneIdNamePairs.append("%d:%s" % (zid, zoneIdToName[zid]))
        out.write("\n    %s = %s%s -- Used in %d zones. (%s)" % (
            repName,
            replacements[repName]["val"],
            [",",""][bool(i==(L-1))],
            len(replacements[repName]["zones"]),
            (", ".join(zoneIdNamePairs))
            ))
        prevVar = curVar
        i+=1
    out.write("\n};\n\n\n")
   
    # MASTER TEXT ID TABLE
    # References common table if id value is shared, or direct int value if unique
    out.write("msgSpecial =\n{")
    comma1 = False
    for zid in zoneVars.keys():
        if comma1:
            out.write(",")
        else:
            comma1 = True
        out.write("\n\n    [%d] = -- %s\n    {" % (zid, zoneIdToName[zid]))
        comma2 = False
        for varName in zoneVars[zid].keys():
            val = zoneVars[zid][varName]
            if comma2:
                out.write(",")
            else:
                comma2 = True
            foundRep = False
            # If the variable name and value is shared with other zones...
            for repName in replacements.keys():
                if (zid in replacements[repName]["zones"]) and (replacements[repName]["targetVar"] == varName):
                    foundRep = True
                    # ... then reference the common table
                    out.write("\n        %s = cm.%s" % (varName, repName))
                    break
            if not foundRep:
                # ... otherwise use the integer literal value
                out.write("\n        %s = %s" % (varName, val))
        out.write("\n    }")
    out.write("\n};\n")
    out.close()
    
    log_messages(cur)

if __name__ == "__main__":
    print("This module should be called from migrate.py")
