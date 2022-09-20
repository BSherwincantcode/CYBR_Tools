#Import necessay libraries
import os
import re
import pprint

#Define Global Variables & Inspection Thresholds
policyModel = {
    #!!!!note all strings are lowercase!!!!
    'PolicyID' : 'Measured Values',
    'policytype' : 'regular',
    'interval' : '1440',
    'immediateinterval' : '5',
    'allowedsafes' : '.*',
    'searchforusages' : 'yes',
    'maximumretries' : '5',
    'mindelaybetweenretries' : '90'
}
iniIndexDict =  dict()
tInterval = 1440
tImmediateInterval = 15

def matchStr(str,regex):
    e = re.compile(regex)
    if e.match(str):
        return True
    else:
        return False

def readINI(file, fullpath):
    fileDict = dict()

    with open(file,'r') as f:
        for l in f:
            if matchStr(l,'\\w') == True and matchStr(l,'\[') == False:
                kv = parseLine(l)
                print('kv')
                print(kv)
                fileDict[kv[0]] = kv[1]
    
    return fileDict

def parseLine(line):
    print('parsing ' + line)
    line = line.lower()
    sLine = line.split('=')
    key = sLine[0]
    if len(sLine) == 1:
        value = 'NULL'
    elif ';' in sLine[1]:
        spLine = sLine[1].split(';')
        value = spLine[0].strip(' \t')
    elif '#' in sLine[1]:
        spLine = sLine[1].split('#')
        value = spLine[0].strip(' \t')
    else:
        value = sLine[1].strip(' \t')
    
    return [key, value]

def analyzeINI(setting, threshold,matchType):
    if matchType is '=':
        for pol in iniIndexDict:
            iniIndexDict[pol][setting]


def main():
    
    #initialize main func variables
    #iniIndexDict.

    #get inputs
    print('Input directory of CPM policy ini files.  Example: "Q:\HealthCheck\VAULT1-PrivateArkFiles\VAULT1-PrivateArkFiles\PasswordManagerShared\Policies"')
    #iniDir = input('"Q:\\HealthCheck\\VAULT1-PrivateArkFiles\\VAULT1-PrivateArkFiles\\PasswordManagerShared\\Policies"')
    iniDir = "Q:\\HealthCheck\\VAULT1-PrivateArkFiles\\VAULT1-PrivateArkFiles\\PasswordManagerShared\\Policies\\pyTest"

    #add a backslash to the tail of the path if it's not there
    if iniDir[-1] != '\\':
        iniDir + '\\\\'

    #build dictionary of all policy inis
    for file in os.listdir(iniDir):
        if file.endswith(".ini"):        
            fullPath = os.fspath(iniDir + '\\' + file)
            funcDict = dict()
            funcDict = readINI(fullPath, file)
            funcDict['Path']=fullPath
            iniIndexDict[funcDict.get('PolicyID')] = funcDict


    pprint.pprint(iniIndexDict)

if __name__ == "__main__":
    main()