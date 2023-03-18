#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\ntruncate time\n"
echo "$($PSQL "TRUNCATE TABLE games, teams, teams_games")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOAL OPP_GOAL
do
  # get names
  #winner
  if [[ $WINNER != 'winner' ]]
  then
    #check if exists
    WIN_ID=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    # if empty
    if [[ -z $WIN_ID ]]
    then
      INSERT_WIN_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WIN_NAME == "INSERT 0 1" ]]
      then
        echo Inserted $WINNER into Teams
      fi
      WIN_ID=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    fi
  fi

  if [[ $OPPONENT != "opponent" ]]
  then
    CHECK_OPP=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    # opp insert into teams
    if [[ -z $CHECK_OPP ]]
    then
      INSERT_OPP_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPP_NAME == "INSERT 0 1" ]]
      then
        echo Inserted $OPPONENT into Teams
      fi
      CHECK_OPP=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    fi
  fi

  #Insert all
  if [[ $ROUND != "round" ]]
  then
    #get ids
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    INSERT_ALL=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WIN_GOAL,$OPP_GOAL)")
    if [[ $INSERT_ALL == "INSERT 0 1" ]]
    then
      echo Inserted $WINNER vs $OPPONENT $ROUND $YEAR $WIN_GOAL $OPP_GOAL + team IDS
    fi
    # insert into teams_courses
    # get ids
    TEAMS_GAMES_INSERT_1=$($PSQL "INSERT INTO teams_games(year,team_id,team_id_2) VALUES($YEAR,$WINNER_ID,$OPPONENT_ID)")
    TEAMS_GAMES_INSERT_2=$($PSQL "INSERT INTO teams_games(year,team_id,team_id_2) VALUES($YEAR,$OPPONENT_ID,$WINNER_ID)")

  fi

done
