if [ ! -f /logs/success ]; then

  Date=$(date '+%F_%H')

  python /app/Main.py >> /logs/log_"$Date".txt 2>&1

fi

if [  "$(date '+%H')" == '16' ]; then
  cd /logs || exit
  tar -czvf /Appdata/logs_"$Date".tar.gz /logs/*
  if [ -n "$ZSTU_WEBDAV_USER" ]; then
    http_code=$(
      \
      curl \
      -u "$ZSTU_WEBDAV_USER:$ZSTU_WEBDAV_PASSWORD" \
      --request "PROPFIND" \
      -o /dev/null \
      -s \
      -w "%{http_code}" \
      --url "$ZSTU_WEBDAV_PATH" \
    )

    if [ "207" != "$http_code" ] && [ "200" != "$http_code" ]; then
      echo -e "Wrong webdav url\n"

    else
      curl --request "PUT" \
      -u "$ZSTU_WEBDAV_USER:$ZSTU_WEBDAV_PASSWORD" \
      --url "$ZSTU_WEBDAV_PATH"/logs_"$Date".tar.gz \
      --data-binary @/Appdata/logs_"$Date".tar.gz
    fi
  fi

  if [ ! -f /logs/success ]; then

    if [ -n "$ZSTU_EMAIL_RECEIVER" ]; then
      postfix start
      echo "$Date" | mail -s "clock in fail" "$ZSTU_EMAIL_RECEIVER"
      postfix stop
    fi

    if [ -n "$ZSTU_SERVER_CHAN_KEY" ]; then

#      if_success=$(
#        curl -d title="clock in fail" \
#        --url https://sctapi.ftqq.com/"$ZSTU_SERVER_CHAN_KEY".send | \
#        grep -Po '"error":"\K[^"]+'
#      )

      curl -d title="clock in fail" \
      --url https://sctapi.ftqq.com/"$ZSTU_SERVER_CHAN_KEY".send

    fi

  elif [ "$(cat /logs/success)" == '0' ]; then

    if [ -n "$ZSTU_EMAIL_RECEIVER" ]; then
      postfix start
      echo "$Date" | mail -s "form updated" "$ZSTU_EMAIL_RECEIVER"
      postfix stop
    fi

    if [ -n "$ZSTU_SERVER_CHAN_KEY" ]; then

      curl -d title="form updated" \
      --url https://sctapi.ftqq.com/"$ZSTU_SERVER_CHAN_KEY".send

    fi
  fi

fi
