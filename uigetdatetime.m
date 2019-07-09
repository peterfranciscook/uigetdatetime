function newTime = uigetdatetime(varargin)
% function newTime = uigetdatetime(varargin)
% 
% uigetdatetime launch a calendar widget to select a date/time
%   newTime = uigetdatetime() launches a calendar widget with the current
%   date and time as the initially selected date/time at 0 hrs offset from
%   UTC
%
%   newTime = uigetdatetime('displayTime',t) launches a calendar widget
%   with `t` as the initially selected date/time at 0 hrs offset from UTC
%   where `t` is a matlab serial date (datenum), datestring (datestr), or
%   datetime object
%
%   newTime = uigetdatetime('displayTime',t,'displayTimeZone',tz) launches
%   a calendar width with `t` as the initially selected date/time with UTC
%   offset associated with string `tz` where tz is a java timezone string.
%   to see a list of allowed timezones:
%       `tzList = cell(java.util.TimeZone.getAvailableIDs)`
%  
%   copyleft 2018 Peter Cook (peter dot cook AT colorado dot edu)
%       with help from yair altman (altmany at gmail dot com)

%parse inputs
p = inputParser;

defaultDisplayTime = now();
defaultTimeZone = 'UTC';
tzList = cell(java.util.TimeZone.getAvailableIDs);

addParameter(p,'displayTime', defaultDisplayTime,...
    @(x) assert(isnumeric(x) || isa(x,'char') || isa(x,'datetime')));
addParameter(p,'displayTimeZone', defaultTimeZone, @(x) ismember(x,tzList))
% addOptional(p,'displayTimeZone', defaultTimeZone)

parse(p,varargin{:})
displayTime = p.Results.displayTime;
displayTimeZone = p.Results.displayTimeZone;
%/parse inputs

%convert input date to datevec
if isnumeric(displayTime)
    currentDatetime = datevec(datetime(displayTime,'convertFrom','datenum',...
        'TimeZone',displayTimeZone));
elseif isa(displayTime,'char')
    try
        currentDatetime = datevec(datetime(displayTime,...
            'convertFrom','datestr','TimeZone',displayTimeZone));
    catch
        currentDatetime = datevec(datetime(now(),'convertFrom','datenum',...
            'TimeZone',displayTimeZone));
    end
elseif isa(displayTime,'datetime')
    currentDatetime = datevec(displayTime);
else
    currentDatetime = datevec(datetime(now(),'convertFrom','datenum',...
        'TimeZone',displayTimeZone));
end

%convert input timezone string to TimeZone object
try
    timeZone = java.util.TimeZone.getTimeZone(displayTimeZone);
catch
    displayTimeZone = 'UTC';
    timeZone = java.util.TimeZone.getTimeZone(displayTimeZone);
end

%init Calendar object
jCal = java.util.Calendar.getInstance();
jCal.set(java.util.Calendar.YEAR, currentDatetime(1))
jCal.set(java.util.Calendar.MONTH, currentDatetime(2)-1)
jCal.set(java.util.Calendar.DAY_OF_MONTH, currentDatetime(3))
jCal.set(java.util.Calendar.HOUR_OF_DAY, currentDatetime(4))
jCal.set(java.util.Calendar.MINUTE, currentDatetime(5))
jCal.set(java.util.Calendar.SECOND, currentDatetime(6))
% jCal.setTimeZone(timeZone)
jCal.setTimeZone(java.util.TimeZone.getDefault())

%init figure for DateChooserPanel
hCalendar = figure();
figPos = get(0,'ScreenSize');
hCalendar.Position = [figPos(1)+figPos(3)/2-272/2,...
    figPos(2)+figPos(4)/2-219/2,272,219];
hCalendar.MenuBar = 'none';
hCalendar.Name = 'Choose Date and Time Range';
hCalendar.NumberTitle = 'off';

% init DateChooserPanel object
jPanel = com.jidesoft.combobox.DateChooserPanel;
jPanel.setTimeDisplayed(true)
% jPanel.setTimeZone(timeZone)
jPanel.setTimeZone(java.util.TimeZone.getDefault())
jPanel.setSelectedCalendar(jCal)

%get java guts of DateChooserPanel Object
[hPanel,~] = javacomponent(jPanel,[0,0,272,219],hCalendar);
set(hPanel,'ShowTodayButton',false)
set(hPanel,'ShowNoneButton',false)
set(hPanel,'ItemStateChangedCallback',...
    @(hPanel,evnt)dateTimeCallbackFcn(hPanel,evnt,hCalendar))

%cribbed from inputdlg.m
if ishghandle(hCalendar)
  % Go into uiwait if the figure handle is still valid.
  % This is mostly the case during regular use.
  c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
  uiwait(hCalendar);
  delete(c);
end
%\cribbed from inputdlg.m


function dateTimeCallbackFcn(~,~,hCalendar)
    
    hModel = hPanel.getSelectionModel;
    
    %get Date object
    jSelectedDate = hModel.getSelectedDate();
    
    %if a date is selected assign the value of newTime
    if ~isempty(jSelectedDate)
        newTime = datetime(jSelectedDate.getTime/1000,'convertFrom','posixtime','TimeZone',char(java.util.TimeZone.getDefault.getID));
    end
    
    %delete figure/container
    delete(hCalendar)
end

%if the figure was deleted instead of the "OK" button pressed, return the
%input datetime
if ~exist('newTime','var')
    newTime = datetime(currentDatetime);
end

end






























