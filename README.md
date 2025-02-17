# Supabase Boilerplate

This is a boilerplate for building applications with **Supabase**. It includes a PostgreSQL schema with user profiles, roles, audit logs, and automated profile creation.

## Features

- **User Profiles**: Automatically creates a profile for each new user.
- **Roles**: Supports role-based access control (e.g., `admin`, `user`).
- **Audit Logs**: Tracks important events like user sign-ups and profile updates.
- **Row Level Security (RLS)**: Ensures users can only access their own data (with exceptions for admins).

## Setup

1. Go to the [Supabase Dashboard](https://supabase.com/dashboard).
2. Navigate to the **SQL Editor**.
3. Paste and run the [setup.sql](setup.sql) script.

## License

This project is licensed under the MIT License.
