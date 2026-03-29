# Purpose: Puma web server configuration.
# WEB_CONCURRENCY controls worker processes (use 2-4 per container in production).
# RAILS_MAX_THREADS controls threads per worker — match to DB pool size.

threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)

# Workers (forked processes) — only in production for better memory utilization.
# WEB_CONCURRENCY=0 means single-process mode (good for development).
if ENV["RAILS_ENV"] == "production"
  workers ENV.fetch("WEB_CONCURRENCY", 2)
  preload_app!
end

plugin :tmp_restart

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
