# uigetdatetime
Simple Interactive Calendar Tool for MATLAB

`uigetdatetime` launches a calendar widget to select a date/time

## Calling Syntax
`function newTime = uigetdatetime(varargin)`
launches a calendar widget with the current date and time as the initially selected date/time at 0 hrs offset from UTC

`newTime = uigetdatetime('displayTime',t)` 
launches a calendar widget with `t` as the initially selected date/time at 0 hrs offset from UTC where `t` is a matlab serial date (datenum), datestring (datestr), or datetime object

`newTime = uigetdatetime('displayTime',t,'displayTimeZone',tz)` launches a calendar width with `t` as the initially selected date/time with UTC offset associated with string `tz` where tz is a java timezone string. to see a list of allowed timezones: `tzList = cell(java.util.TimeZone.getAvailableIDs)`

copyleft 2018 Peter Cook (peter dot cook AT colorado dot edu) with help from yair altman (altmany at gmail dot com)
