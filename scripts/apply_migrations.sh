#!/bin/bash

# Apply Supabase migrations to the database
echo "Applying Supabase migrations..."
supabase db push

# Run the clean database script
echo "Cleaning database (preserving users)..."
# The correct way to execute SQL against the remote database
cat ./scripts/clean_db.sql | supabase db dump --file - exec

echo "Database updated successfully!" 