-- Enable Row Level Security (RLS) for the `auth.users` table
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create the `roles` table
CREATE TABLE public.roles (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- Insert default roles
INSERT INTO public.roles (name, description)
VALUES 
    ('admin', 'Administrator with full access'),
    ('user', 'Regular user with limited access');

-- Create the `profiles` table
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    role_id INT REFERENCES public.roles(id) DEFAULT 2,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Enable Row Level Security (RLS) for the `profiles` table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for the `profiles` table
CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.role_id = 1
));

-- Create the `audit_logs` table
CREATE TABLE public.audit_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users ON DELETE SET NULL,
    action TEXT NOT NULL,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Automatically create a profile when a new user is registered
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, username, full_name, avatar_url, bio, role_id)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name', NULL, NULL, 2);

    INSERT INTO public.audit_logs (user_id, action, details)
    VALUES (NEW.id, 'sign_up', jsonb_build_object('email', NEW.email));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();
