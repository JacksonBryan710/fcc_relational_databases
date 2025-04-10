#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to my salon, how may I help you?\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #print services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #make appointment
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) APPOINTMENT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

APPOINTMENT () {
  #get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #get service info
  SERVICE_NAME_UF=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME_UF | sed 's/ //g')

  #get service time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, '$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
