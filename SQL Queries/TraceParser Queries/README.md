## WARNING
I am not a SQL admin, or a DBA, or even an amatuer.  I'm someone who needed some tools and cobbled them together as quickly as I could.  There is no optimization or even best practices being observed within these queries.  Honestly, I don't even know any SQL best practices or optimization techniques other than to avoid full joins.

## Trace Parser Analysis
These queries will work against MYSQL databases that have been populated with CyberArk's internal TraceParser tool. Only internal employees are granted access to this tool. Analysis from the queries within this repo may or may not aid in troubleshooting specific issues.  This were created with the aim of identifying very specific behavioral problems within a unique environment with  a unique use case.

I am sharing these to better arm my colleagues to perform similar analysis.

Please note, identifying information has been removed or altered within the queries, so you may need to update several values and field names.

## TrasePraser Data Field Parsing
This collection of scripts allows for analyzing performance for specific services against specific safes/files when performed by specific users.

Order of operations:
1. ServiceAnalysis.CreateTables.sql
2. ServiceAnalysis.PopulateRAW.sql
3. ServiceAnalysis.ParseData.sql

Additional queries can now be executed against data_parsed