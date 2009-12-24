# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_test_project_session',
  :secret      => '3259e250a08319c22b1c91a82359afec7d0d84b4b22919664fa7af2d7a6834cbd8c486ee83cb0aef7391772789e026f3d38b5b6dad319353a73b0c4a6dbfa3bf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
