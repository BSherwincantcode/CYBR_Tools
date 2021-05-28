#import CSV library
import csv

#declare input and output files


with open("Q:\HealthCheck\CA1_Table_Extract_20210512\CA1_dbo_CAObjectProperties.csv","r") as source:
    reader = csv.reader(source)
    
    # "newline=''" option removes \r\n from output, eliminating blank lines between rows in Windows CSVs
    with open ("Q:\HealthCheck\CA1_Table_Extract_20210512\CA1_dbo_CAObjectProperties_clean.csv","w",newline='') as result:
        writer = csv.writer(result)
        for r in reader:
            if len(r) == 7:
                writer.writerow((r[0],r[1],r[2],r[3],r[4]))
            else:
                print(r)
                print(len(r))
            #print(r[0],r[1],r[2],r[3],r[4])
            #each column is assigned an index, print only the columns you want to keep  
            #writer.writerow((r[0],r[1],r[2],r[3],r[4]))4