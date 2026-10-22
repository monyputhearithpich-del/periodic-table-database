#!/bin/bash
# Look up an element by atomic number, symbol, or name.

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  CONDITION="e.atomic_number = $1"
else
  CONDITION="e.symbol = '$1' OR e.name = '$1'"
fi

QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, TRIM(TRAILING '0' FROM TRIM(TRAILING '.' FROM p.atomic_mass::TEXT)), p.melting_point_celsius, p.boiling_point_celsius \
FROM elements e \
JOIN properties p ON e.atomic_number = p.atomic_number \
JOIN types t ON p.type_id = t.type_id \
WHERE $CONDITION;"

RESULT=$($PSQL "$QUERY")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
