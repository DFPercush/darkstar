import re
import os.path
import TextIDs
import lupa
from lupa import LuaRuntime
import migrate

textIDFilename = "../scripts/globals/TextIDs.lua"

def updateTextIDs():
    zoneNameToId = {}
    zoneIdToName = {}
    migrate.connect()
    migrate.cur.execute("SELECT zoneid,name FROM zone_settings;")
    rows = migrate.cur.fetchall()
    for row in rows:
        zoneId = int(row[0])
        zoneName = row[1]
        zoneIdToName[zoneId] = zoneName
        zoneNameToId[zoneName] = zoneId

    lua = LuaRuntime()
    #print(lua.eval("1+1"))
    if not os.path.isfile(textIDFilename):
        print ("Can not find " + textIDFilename)
        exit()
    f = open(textIDFilename, "r")
    fileContents = f.read()
    f.close()
    unfoundFiles = []
    preComments = []
    lineCount = 0
    for line in fileContents.split("\n"):
        lineCount += 1
        line = line.strip()
        if lineCount in [1, 2]:
            pass
        elif (line[0:2] == "--"):
            m = re.search("\\-\\- Could not open (.*\\.lua)", line)
            if (m):
                unfoundFiles.append(m.group(1))
            else:
                preComments.append(line)
        elif (len(line) > 0):
            break;
    lua.execute(fileContents)
    G = lua.globals()
    zoneVars = G["msgSpecial"]
    replacements, uniques = TextIDs.BuildCommonAndUnique(zoneVars)
    TextIDs.writeOut(zoneVars, replacements, uniques, unfoundFiles, preComments, zoneNameToId, zoneIdToName, textIDFilename)

# Main
if __name__ == "__main__":
    updateTextIDs()
    print(textIDFilename + " has been updated.")
