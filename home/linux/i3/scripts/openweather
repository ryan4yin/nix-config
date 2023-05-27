#!/usr/bin/env bash
# Edited by Andreas Lindlbauer <endeavouros.mousily@aleeas.com>

temps=("#0600FF" "#0500FF" "#0400FF" "#0300FF" "#0200FF" "#0100FF" "#0000FF" "#0002FF" "#0012FF" "#0022FF" "#0032FF" "#0044FF" "#0054FF" "#0064FF" "#0074FF" "#0084FF" "#0094FF" "#00A4FF" "#00B4FF" "#00C4FF" "#00D4FF" "#00E4FF" "#00FFF4" "#00FFD0" "#00FFA8" "#00FF83" "#00FF5C" "#00FF36" "#00FF10" "#17FF00" "#3EFF00" "#65FF00" "#B0FF00" "#FDFF00" "#FFF000" "#FFDC00" "#FFC800" "#FFB400" "#FFA000" "#FF8C00" "#FF7800" "#FF6400" "#FF5000" "#FF3C00" "#FF2800" "#FF1400" "#FF0000")

command -v jq >/dev/null 2>&1 || { echo >&2 "Program 'jq' required but it is not installed.  
Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "Program 'wget' required but is not installed.  
Aborting."; exit 1; }

# To use this script you need to create an API key here https://home.openweathermap.org
# You need to put your Open Weather APIKEY here:
APIKEY="keykeykey"
# And get your Latitute and Longitudes to put in here:
LAT="XX.XXXX"
LON="XX.XXXX"
URL="http://api.openweathermap.org/data/2.5/onecall?lat=${LAT}&lon=${LON}&units=metric&exclude=minutely,hourly,daily&APPID=${APIKEY}"
WEATHER_RESPONSE=$(wget -qO- "${URL}")

WEATHER_CONDITION=$(echo "$WEATHER_RESPONSE" | jq '.current.weather[0].main' | sed 's/"//g')
WEATHER_TEMP=$(echo "$WEATHER_RESPONSE" | jq '.current.feels_like')
WEATHER_INT=${WEATHER_TEMP%.*}

TIME_NOW=$( echo "$WEATHER_RESPONSE" | jq '.current.dt')
SUNRISE=$( echo "$WEATHER_RESPONSE" | jq '.current.sunrise')
SUNSET=$( echo "$WEATHER_RESPONSE" | jq '.current.sunset')
DESCRIPTION=$( echo "$WEATHER_RESPONSE" | jq '.current.weather[0].description' | sed 's/"//g')
WEATHER_ALERT=$( echo "$WEATHER_RESPONSE" | jq '.alerts[0].event' | sed 's/"//g')
DAYTIME="n"

if [[ "$TIME_NOW" > "$SUNRISE" ]] && [[ "$TIME_NOW" < "$SUNSET" ]]; then
    DAYTIME="d"
fi

case $WEATHER_CONDITION in
  'Clouds')
    if [ "$DAYTIME" == "d" ]; then
        WEATHER_ICON=""
    else
        WEATHER_ICON=""
    fi
    ;;
  'Rain')
    WEATHER_ICON=""
    ;;
  'Drizzle')
    if [ "$DAYTIME" == "d" ]; then
        WEATHER_ICON="" 
    else
        WEATHER_ICON=""
    fi
    ;;
  'Thunderstorm')
    WEATHER_ICON=""
    ;;
  'Snow')
    WEATHER_ICON=""
    ;;
  'Clear')
    if [ "$DAYTIME" == "d" ]; then
        WEATHER_ICON=""
    else
        WEATHER_ICON=""
    fi
    ;;
  *)
    WEATHER_ICON="🌫"
    ;;
esac

WEATHER_COLOR="#FFFFFF"
if [ "$WEATHER_INT" -lt "-11" ]; then
    WEATHER_COLOR="#0000FF"
elif [ "$WEATHER_INT" -gt 35 ]; then
    WEATHER_COLOR="#FF0000"
else
    WEATHER_INT=$(( WEATHER_INT + 11 )) 
    WEATHER_COLOR="${temps[$WEATHER_INT]}"
fi

full_text="${WEATHER_ICON}  ${WEATHER_TEMP}°C: ${DESCRIPTION} "
if [ "$WEATHER_ALERT" != "null" ]; then
    WARN_START=$(echo "$WEATHER_RESPONSE" | jq '.alerts[0].start')
    WARN_END=$(echo "$WEATHER_RESPONSE" | jq '.alerts[0].end')
    WARN_START=$(date -d @"$WARN_START" +%a_%k:%M)
    WARN_END=$(date -d @"$WARN_END" +%a_%k:%M)
    full_text="${WEATHER_ICON}  ${WEATHER_TEMP}°C: ${DESCRIPTION}  ${WEATHER_ALERT} from ${WARN_START} to ${WARN_END}  "
fi


echo "${full_text}"
echo "${WEATHER_TEMP}°C "
echo "${WEATHER_COLOR}"
