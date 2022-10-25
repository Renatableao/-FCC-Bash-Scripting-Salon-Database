#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON MUDITA ~~~~~\n\n" 

BOOK_SERVICE() {
  if [[ $1 ]] 
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to Salon Mudita, how can I help you?\n"
  fi

  # display service menu
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  # get user selection
  read SERVICE_ID_SELECTED
  
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED  =~ ^[0-9]+$ ]] 
  then 
    # send to service menu
    BOOK_SERVICE "Invalid option. Select a service:"
  else
    
    # check if selected option is on the service list
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # if not valid service
    if [[ -z $SERVICE_NAME ]]
    then
      # send to service menu
      BOOK_SERVICE "Invalid option. Select a service:"
    else
      # get customer phone
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]] 
      then 
        # get customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
      echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ //g'), $(echo $CUSTOMER_NAME | sed 's/ //g')?"  
     
      # get user date selection
      read SERVICE_TIME

      # make appointment and register on database
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //g')."
      REGISTER_APPOINMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")    
    fi
  fi
} 

BOOK_SERVICE