#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --csv -t -c"
MAIN_MENU (){
  if [[ ! -z $1 ]]
  then echo -e "$1"
  fi
  echo -e "\nPlease choose a service.\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo $SERVICES | sed -E 's/ *([0-9]+)/\n\1/g' | while read service
  do
  if [[ ! -z $service ]]
  then
  echo $service | sed 's/,/) /g'
  fi
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [0-9]+ ]]
  then
  MAIN_MENU "\nPlease pick a valid service number."
  else
  SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_RESULT ]]
  then
  MAIN_MENU "\nPlease pick a valid service number."
  else
  echo -e "\nPlease enter your phone number.\n"
  read CUSTOMER_PHONE
  PHONE_RESULT=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $PHONE_RESULT ]]
  then
  echo -e "\nWhat is your name?\n"
  read CUSTOMER_NAME
  echo -e "\nWelcome $CUSTOMER_NAME\n"
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
  CUSTOMER_NAME=$PHONE_RESULT
  echo -e "\nWelcome $CUSTOMER_NAME\n"
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nAt what time would you like to have your appointment?\n"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "I have put you down for a $SERVICE_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."
  exit
  fi
  fi  
}
#TRUNCATE_RESULT=$($PSQL "TRUNCATE appointments, customers")
MAIN_MENU
