xquery version "1.0-ml";
import module namespace temporal = "http://marklogic.com/xdmp/temporal" at "/MarkLogic/temporal.xqy";


if ("%SD_TEMPORAL_MODE%" -eq "true")
then temporal:collection-set-options("%SD_TEMPORAL_COLLECTION%", ("updates-safe"))
else ()