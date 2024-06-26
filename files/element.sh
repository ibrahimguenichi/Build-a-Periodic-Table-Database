#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
ARGUMENT=$1

PRINT_ELEMENT () {
  if [[ -z $ARGUMENT ]]
  then
    echo "Please provide an element as an argument."
  else
    SEARCH_ELEMENT
  fi
}

SEARCH_ELEMENT() {
  #determine the input
  if [[ $ARGUMENT =~ ^[1-9]+$ ]]
  then
    ATOMIC_NUMBER=$ARGUMENT
  elif [[ $ARGUMENT =~ ^[A-Z] ]] && [[ $(echo $ARGUMENT | wc -c)-1 -le 2 ]]
  then
    SYMBOL=$ARGUMENT
  elif [[ $ARGUMENT =~ ^[A-Z]* ]]
  then
    NAME=$ARGUMENT
  else
    echo "Argument '$ARGUMENT' is not a valid atomic number or symbol."
  fi

  #search for the element in the database
  if [[ ! -z $ATOMIC_NUMBER ]]
  then
    SEARCH_ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME <<< "$SEARCH_ELEMENT"
    IFS=" "
  elif [[ ! -z $SYMBOL ]]
  then
    SEARCH_ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol = '$SYMBOL'")
    IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME <<< "$SEARCH_ELEMENT"
    IFS=" "
  elif [[ ! -z $NAME ]]
  then
    SEARCH_ELEMENT=$($PSQL "SELECT * FROM elements WHERE name = '$NAME'")
    IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME <<< "$SEARCH_ELEMENT"
    IFS=" "
  fi

  # test if the element exists
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    #get the element properties
    SEARCH_PROPERTIES=$($PSQL "SELECT * FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    IFS="|" read -r ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID <<< "$SEARCH_PROPERTIES"
    IFS=" "
    
    #get the type of the element
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")

    #print the element
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    fi
}

PRINT_ELEMENT