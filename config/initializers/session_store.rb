# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_jsrdemo_session',
  :secret      => '48c99ff5bc460804233ef316cb19ca11529baff02157747f60f76e7254531a4c25ecb17958aaee06cc1afb70e2595956d19d8f1eaa8b063cde5f3c241a0bf3f7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
