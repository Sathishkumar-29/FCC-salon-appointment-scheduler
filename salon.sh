#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

  AVALIABLE_SERVICES=$($PSQL  "select service_id, name from services order by  service_id")
  echo $AVALIABLE_SERVICES
  if [[ -z $AVALIABLE_SERVICES ]]
  then
  echo "Sorry, we dont have any service available now.."
  else
  echo "$AVALIABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
 read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
     MAIN_MENU "That is not a number"
     else
      SERV_AVAILABLE=$($PSQL "select service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
      NAME_SERVICE=$($PSQL "select name FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
  if [[ -z $SERV_AVAILABLE ]]
    then
     MAIN_MENU "I could not find that service. What would you like today?"
    else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "select name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      echo -e "\nWhat time would you like your $NAME_SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "select customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ $SERVICE_TIME ]]
      then
      INSERT_SERV_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
     if [[ $INSERT_SERV_RESULT ]]
    then
    echo -e "\nI have put you down for a $NAME_SERVICE at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
   fi
   fi
  fi
  fi
}

MAIN_MENU
