# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
# Added :password_confirmation, :api_key, :authorization to cover common auth patterns
Rails.application.config.filter_parameters += [
  :passw, :password_confirmation, :email, :secret, :token, :api_key,
  :_key, :crypt, :salt, :certificate, :otp, :ssn, :authorization
]
