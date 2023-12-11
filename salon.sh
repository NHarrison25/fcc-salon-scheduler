#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SALON_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nWhat service would you like? (Choose a menu number):"
  read SERVICE_ID_SELECTED
  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    SALON_MENU "Please enter a valid service ID."
  else
    echo -e "\nPlease enter your phone number (xxx-xxxx):"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nIt looks like you're a new customer! Please enter your name:"
      read CUSTOMER_NAME
      #add new customer
      NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      #get appt time
      echo -e "\nThank you for joining us, $CUSTOMER_NAME!"
      echo -e "\nWhat time would you like your appointment to be at?"
      read SERVICE_TIME
      #add appt
      ADD_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      SERVICE_NAME_PRETTY=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
      echo "I have put you down for a $SERVICE_NAME_PRETTY at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      CUSTOMER_NAME_PRETTY=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME_PRETTY'")
      echo -e "\nWelcome back, $CUSTOMER_NAME_PRETTY!"
      echo -e "\nWhat time would you like your appointment to be at?"
      read SERVICE_TIME
      ADD_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    fi
  fi
}

SALON_MENU
