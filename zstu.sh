if [ ! -f /logs/success ]; then

  Date=$(date '+%F_%H')

  python /app/Main.py > /logs/log_"$Date".txt 2>&1

fi

if [  "$(date '+%H')" == '20' ]; then

  if [ ! -f /logs/success ]; then
    postfix start
    tar -czvf logs_"$Date".tar.gz /logs
    echo "$Date" | mail -s "clock in fail" hahaleyile@126.com

  elif [ "$(cat /logs/success)" == '0' ]; then
    postfix start
    echo "$Date" | mail -s "Form updated" hahaleyile@126.com
  fi

fi

