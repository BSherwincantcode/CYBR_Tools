import os
import re
import xml.etree.ElementTree as et

file = "Q:\HealthCheck\EPAM1_ENE\Rules.xml"

tree = et.parse(file)

root = tree.getroot()


def matchStr(str,regex):
    e = re.compile(regex)
    if e.match(str):
        return True
    else:
        return False

def findstr(l):
    e = re.complile('<Rule ID="(\d_+)"')
    g = re.compile('.*RecipientTO="(.*).*"')
    

'''for set in root:
    for rec in set.iter('Output'):
        print(set.tag,":",set.attrib)
        print(rec.attrib)
        for i in rec:
            print(i.tag, ": ",i.attrib)'''

with open(file,'r') as f:
    for l in f:
        
