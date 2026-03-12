# Intro

Messing about with AWS Glue: Creating a database, crawler, etl job, athena qureies

# Running stuff

run `./crawler-create.sh` to create a data bucket, load it with data, create a crawler, run it, and use an Athena saved query to see the results.
run `./crawler-delete.sh` to remove everything.

# Technotes

Creating a table is not needed as the crawler will create one on its first run.
