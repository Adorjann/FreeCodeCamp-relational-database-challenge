#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games,teams")

RUN_QUERY () {
  RETURN_VALUE=$($PSQL "$1")
}


cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    #get team_id of winner team
    RUN_QUERY "SELECT team_id FROM teams WHERE name = '$WINNER'"
    WINNER_ID=$RETURN_VALUE
    #if not found
    if [[ -z $RETURN_VALUE ]]
    then
      #insert winner team
      RUN_QUERY "INSERT INTO teams(name) VALUES('$WINNER')"
      if [[ $RETURN_VALUE == "INSERT 0 1" ]]
      then 
        echo Insert into teams: $WINNER
      fi  
      #get team_id of new winner team
      RUN_QUERY "SELECT team_id FROM teams WHERE name = '$WINNER'"
      WINNER_ID=$RETURN_VALUE
    fi
    #get team_id of opponent team
    RUN_QUERY "SELECT team_id FROM teams WHERE name = '$OPPONENT'"
    OPPONENT_ID=$RETURN_VALUE
    #if not found
    if [[ -z $RETURN_VALUE ]]
    then
      #insert opponent team
      RUN_QUERY "INSERT INTO teams(name) VALUES('$OPPONENT')"
      if [[ $RETURN_VALUE == "INSERT 0 1" ]]
      then
        echo Insert into teams: $OPPONENT
      fi
      #get team_id of new opponent team
      RUN_QUERY "SELECT team_id FROM teams WHERE name = '$OPPONENT'"
      OPPONENT_ID=$RETURN_VALUE
    fi
    #insert into games
    RUN_QUERY "INSERT INTO games(year,round,winner_goals,opponent_goals,winner_id,opponent_id) VALUES($YEAR,'$ROUND',$WINNER_GOALS,$OPPONENT_GOALS,$WINNER_ID,$OPPONENT_ID)"
    if [[ $RETURN_VALUE == "INSERT 0 1" ]]
      then 
        echo + Game Inserted
      fi 
  fi
done
