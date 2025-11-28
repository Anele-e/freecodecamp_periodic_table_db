#!/bin/bash

# sudo service postgresql start

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


GET_ATOMIC_ECHO() {
  
  NAME_AND_SYMBOL=$($PSQL "SELECT name, symbol FROM elements WHERE atomic_number = '$1';")
  if [[ -z "$NAME_AND_SYMBOL" ]]; then
    echo "I could not find that element in the database."
    exit 0
  fi
  IFS="|" read -r NAME SYMBOL <<< "$NAME_AND_SYMBOL"
  X=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = '$1';")
  IFS="|" read -r MASS MELTING BOILING T_ID <<< "$X"
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$T_ID'")
  echo -e "The element with atomic number $1 is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

GET_SYMBOL_AND_ECHO() {
  NAME_AND_ATOMIC=$($PSQL "SELECT name, atomic_number FROM elements WHERE symbol = '$1';")
  if [[ -z "$NAME_AND_ATOMIC" ]]; then
    GET_NAME_AND_ECHO $1
    exit 0
  fi
  IFS="|" read -r NAME ATOMIC <<< "$NAME_AND_ATOMIC"
  X=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = '$ATOMIC';")
  IFS="|" read -r MASS MELTING BOILING T_ID <<< "$X"
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$T_ID'")
  echo -e "The element with atomic number $ATOMIC is $NAME ($1). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

GET_NAME_AND_ECHO() {

  SYMBOL_AND_ATOMIC=$($PSQL "SELECT symbol, atomic_number FROM elements WHERE name = '$1';")
  if [[ -z "$SYMBOL_AND_ATOMIC" ]]; then
    echo "I could not find that element in the database."
    exit 0
  fi

  IFS="|" read -r SYMBOL ATOMIC <<< "$SYMBOL_AND_ATOMIC"
  X=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = '$ATOMIC';")
  IFS="|" read -r MASS MELTING BOILING T_ID <<< "$X"
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$T_ID'")
  echo -e "The element with atomic number $ATOMIC is $1 ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $1 has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

if [[ -z "$1" ]]
then 
  echo "Please provide an element as an argument."
elif [[ "$1" =~ ^[0-9]+$ ]]
then
  GET_ATOMIC_ECHO "$1"
elif [[ ${#1} -ge 1 ]]
then
  GET_SYMBOL_AND_ECHO "$1"
fi
