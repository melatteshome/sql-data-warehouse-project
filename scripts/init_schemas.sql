/*
=============================================================
Create Schemas
=============================================================
Script Purpose:
    This script checks if the schemas have been created already 
    and sets up the three schemas that we already defined
    in our data archetecture for our project 'bronze', 'silver', and 'gold'.
    This script is run on a database connection that has been set already.

*/

CREATE SCHEMA IF NOT EXISTS Bronze;

CREATE SCHEMA IF NOT EXISTS Silver;

CREATE SCHEMA IF NOT EXISTS Gold;
