# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_activerecord_session',
  :secret      => 'da386476874cae9998f7e38e17e2a1c66f04471ce3727a3a425191dac096ce73956f8d61a9f37b60d7e1f87d72c10363785320f51a438b0b865a5bba45d79fae'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
