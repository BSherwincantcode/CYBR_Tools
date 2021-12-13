#Connect to MSSQL EVD Export
#Pull data from EVD SQL database
#For each CPM, determine which safes they own and which platforms are associated with that safe

#Imports data from MSSQL
try:
    import pyodbc
except ImportError:
    raise ImportError('pyODBC library required - please install from pip')

sqlDriver = '{ODBC Driver 17 for SQL Server}'
server = 'localhost'
database = 'CyberArk'
sqlUser = 'scripttestid'
sqlPW = 'Cyberark1'
connection = pyodbc.connect('Driver='+sqlDriver+';SERVER='+server+';DATABASE='+database+';UID='+sqlUser+';PWD='+sqlPW)

cursor = connection.cursor()
cursor.execute("Select DISTINCT((CAOwners.CAOOwnerName+'~~~'+CAObjectProperties.CAOPObjectPropertyValue)),CAOwners.CAOOwnerName,CAObjectProperties.CAOPObjectPropertyValue from CAOwners INNER JOIN CAObjectProperties on CAOwners.CAOSafeID = CAOPSafeId WHERE CAOwners.CAOOwnerID IN (Select CAUUserID from CAUsers where CAUUserTypeID = '31') AND CAOPObjectPropertyName = 'PolicyID'")

out = {}

while 1:
    row = cursor.fetchone()
    if not row:
        break
    print(row)
    if not out.get(row.CAOOwnerName):
        out.update({row.CAOOwnerName:[row.CAOPObjectPropertyValue]})
#    elif:
 #       not out.get[row.CAOwnerName]
    else:
        out[row.CAOOwnerName].append(row.CAOPObjectPropertyValue)


cursor.close()
connection.close()

for key in out:
    print(key+": ")
    print(*out[key],sep=",")