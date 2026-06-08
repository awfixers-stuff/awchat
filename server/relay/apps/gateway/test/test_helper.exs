ExUnit.start()

# Unit tests do not require the OTP application (Postgres, Bandit, etc.).
System.put_env("MIX_ENV", "test")