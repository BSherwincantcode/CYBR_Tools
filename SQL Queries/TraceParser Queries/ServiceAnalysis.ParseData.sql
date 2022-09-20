-- I recommend not touching this script, at all.  Ignore the little weirdness within the single quotes '' within the substring_index arguments, 
-- that is a "Unit Separator" and is basically a fancy delimeter in the data field.


INSERT INTO data_parsed(TransactionID,SafeFilter,FileFilter,CatIDs,CatValues,SearchInAllValues)
SELECT transactionid,
	RIGHT(SUBSTRING_INDEX(rawData,'',2),(LENGTH(SUBSTRING_INDEX(rawData,'',2))-LOCATE('SafeName=',SUBSTRING_INDEX(rawData,'',2))-8)) as SafeFilter,
	RIGHT(SUBSTRING_INDEX(rawData,'',3),(LENGTH(SUBSTRING_INDEX(rawData,'',3))-LOCATE('FileName=',SUBSTRING_INDEX(rawData,'',3))-8)) as FileFilter,
	RIGHT(SUBSTRING_INDEX(rawData,'',20),(LENGTH(SUBSTRING_INDEX(rawData,'',20))-LOCATE('FindCategoriesIds=',SUBSTRING_INDEX(rawData,'',20))-18)) as CategoryIDs,
	RIGHT(SUBSTRING_INDEX(rawData,'',21),(LENGTH(SUBSTRING_INDEX(rawData,'',21))-LOCATE('FindCategoriesValues=',SUBSTRING_INDEX(rawData,'',21))-22)) as CategoryValues,
	RIGHT(SUBSTRING_INDEX(rawData,'',24),(LENGTH(SUBSTRING_INDEX(rawData,'',24))-LOCATE('SearchInAllValues=',SUBSTRING_INDEX(rawData,'',24))-17)) as SearchAllValues
from data_RAW;

select * from trace.data_parsed ;