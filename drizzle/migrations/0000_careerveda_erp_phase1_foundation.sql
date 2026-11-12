CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL DEFAULT 'New employee',
  email text NOT NULL DEFAULT '',
  job_title text,
  department text,
  manager_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  avatar_url text,
  employment_status text NOT NULL DEFAULT 'active' CHECK (employment_status IN ('active', 'suspended')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.profiles TO authenticated;
GRANT UPDATE (full_name, avatar_url) ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.app_roles (
  role_key text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  description text NOT NULL DEFAULT '',
  sort_order integer NOT NULL DEFAULT 100,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.app_roles TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.app_roles TO authenticated;
GRANT ALL ON public.app_roles TO service_role;
ALTER TABLE public.app_roles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.role_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role_key text NOT NULL REFERENCES public.app_roles(role_key) ON DELETE CASCADE,
  module text NOT NULL,
  action text NOT NULL,
  access_scope text NOT NULL CHECK (access_scope IN ('own', 'team', 'organization')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (role_key, module, action, access_scope)
);
GRANT SELECT ON public.role_permissions TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.role_permissions TO authenticated;
GRANT ALL ON public.role_permissions TO service_role;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_key text NOT NULL REFERENCES public.app_roles(role_key) ON DELETE RESTRICT,
  assigned_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role_key)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.operational_responsibilities (
  responsibility_key text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  description text NOT NULL DEFAULT '',
  sort_order integer NOT NULL DEFAULT 100,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.operational_responsibilities TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.operational_responsibilities TO authenticated;
GRANT ALL ON public.operational_responsibilities TO service_role;
ALTER TABLE public.operational_responsibilities ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.user_responsibilities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  responsibility_key text NOT NULL REFERENCES public.operational_responsibilities(responsibility_key) ON DELETE RESTRICT,
  assigned_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, responsibility_key)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_responsibilities TO authenticated;
GRANT ALL ON public.user_responsibilities TO service_role;
ALTER TABLE public.user_responsibilities ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text NOT NULL DEFAULT '',
  manager_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.teams TO authenticated;
GRANT ALL ON public.teams TO service_role;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.team_memberships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  membership_role text NOT NULL DEFAULT 'member' CHECK (membership_role IN ('manager', 'member')),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (team_id, user_id)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.team_memberships TO authenticated;
GRANT ALL ON public.team_memberships TO service_role;
ALTER TABLE public.team_memberships ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.employee_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL,
  full_name text NOT NULL,
  invited_user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  invited_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  role_key text NOT NULL REFERENCES public.app_roles(role_key) ON DELETE RESTRICT,
  responsibility_key text REFERENCES public.operational_responsibilities(responsibility_key) ON DELETE SET NULL,
  team_id uuid REFERENCES public.teams(id) ON DELETE SET NULL,
  invitation_status text NOT NULL DEFAULT 'pending' CHECK (invitation_status IN ('pending', 'accepted', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (email, invitation_status)
);
GRANT SELECT, INSERT, UPDATE ON public.employee_invitations TO authenticated;
GRANT ALL ON public.employee_invitations TO service_role;
ALTER TABLE public.employee_invitations ENABLE ROW LEVEL SECURITY;

CREATE INDEX profiles_manager_id_idx ON public.profiles(manager_id);
CREATE INDEX user_roles_user_id_idx ON public.user_roles(user_id);
CREATE INDEX user_roles_role_key_idx ON public.user_roles(role_key);
CREATE INDEX role_permissions_lookup_idx ON public.role_permissions(role_key, module, action, access_scope);
CREATE INDEX user_responsibilities_user_id_idx ON public.user_responsibilities(user_id);
CREATE INDEX team_memberships_user_id_idx ON public.team_memberships(user_id);
CREATE INDEX team_memberships_team_id_idx ON public.team_memberships(team_id);
CREATE INDEX employee_invitations_invited_by_idx ON public.employee_invitations(invited_by);

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role_key = 'super_admin'
  );
$$;
REVOKE ALL ON FUNCTION public.is_super_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.has_role(_role_key text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.role_key = _role_key
  );
$$;
REVOKE ALL ON FUNCTION public.has_role(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_role(text) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.has_permission(_module text, _action text, _scope text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.role_permissions rp ON rp.role_key = ur.role_key
    WHERE ur.user_id = auth.uid()
      AND rp.module = _module
      AND rp.action = _action
      AND rp.access_scope = _scope
  );
$$;
REVOKE ALL ON FUNCTION public.has_permission(text, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_permission(text, text, text) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.shares_team_with(_target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.team_memberships mine
    JOIN public.team_memberships theirs ON theirs.team_id = mine.team_id
    WHERE mine.user_id = auth.uid()
      AND theirs.user_id = _target_user_id
  );
$$;
REVOKE ALL ON FUNCTION public.shares_team_with(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.shares_team_with(uuid) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.can_manage_team(_team_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT public.is_super_admin()
    OR public.has_permission('teams', 'manage', 'organization')
    OR (
      public.has_permission('teams', 'manage', 'team')
      AND EXISTS (
        SELECT 1
        FROM public.team_memberships tm
        WHERE tm.team_id = _team_id
          AND tm.user_id = auth.uid()
          AND tm.membership_role = 'manager'
      )
    );
$$;
REVOKE ALL ON FUNCTION public.can_manage_team(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.can_manage_team(uuid) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(btrim(NEW.raw_user_meta_data ->> 'full_name'), ''), NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''), 'New employee'),
    COALESCE(NEW.email, '')
  )
  ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        full_name = CASE
          WHEN public.profiles.full_name = 'New employee' THEN EXCLUDED.full_name
          ELSE public.profiles.full_name
        END,
        updated_at = now();
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.sync_user_email()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.email IS DISTINCT FROM OLD.email THEN
    UPDATE public.profiles
    SET email = COALESCE(NEW.email, ''), updated_at = now()
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.sync_user_email() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER on_auth_user_created_careerveda_profile
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER on_auth_user_email_updated_careerveda_profile
AFTER UPDATE OF email ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.sync_user_email();

CREATE POLICY "Employees read own or permitted profiles"
ON public.profiles FOR SELECT TO authenticated
USING (
  id = auth.uid()
  OR public.is_super_admin()
  OR public.has_permission('employees', 'read', 'organization')
  OR (
    public.has_permission('employees', 'read', 'team')
    AND public.shares_team_with(id)
  )
);
CREATE POLICY "Employees update their own profile fields"
ON public.profiles FOR UPDATE TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());
CREATE POLICY "Super admins manage employee profiles"
ON public.profiles FOR UPDATE TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "Signed-in employees read available roles"
ON public.app_roles FOR SELECT TO authenticated
USING (true);
CREATE POLICY "Only super admins manage roles"
ON public.app_roles FOR ALL TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "Signed-in employees read role permissions"
ON public.role_permissions FOR SELECT TO authenticated
USING (true);
CREATE POLICY "Only super admins manage role permissions"
ON public.role_permissions FOR ALL TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "Employees read own role assignments; admins read all"
ON public.user_roles FOR SELECT TO authenticated
USING (user_id = auth.uid() OR public.is_super_admin());
CREATE POLICY "Only super admins assign system roles"
ON public.user_roles FOR INSERT TO authenticated
WITH CHECK (public.is_super_admin());
CREATE POLICY "Only super admins update system roles"
ON public.user_roles FOR UPDATE TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());
CREATE POLICY "Only super admins remove system roles"
ON public.user_roles FOR DELETE TO authenticated
USING (public.is_super_admin());

CREATE POLICY "Signed-in employees read operational responsibilities"
ON public.operational_responsibilities FOR SELECT TO authenticated
USING (true);
CREATE POLICY "Only super admins manage responsibility templates"
ON public.operational_responsibilities FOR ALL TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "Employees read own responsibilities; admins and managers read scoped records"
ON public.user_responsibilities FOR SELECT TO authenticated
USING (
  user_id = auth.uid()
  OR public.is_super_admin()
  OR public.has_permission('employees', 'read', 'organization')
  OR (public.has_permission('employees', 'read', 'team') AND public.shares_team_with(user_id))
);
CREATE POLICY "Only super admins assign operational responsibilities"
ON public.user_responsibilities FOR INSERT TO authenticated
WITH CHECK (public.is_super_admin());
CREATE POLICY "Only super admins change operational responsibilities"
ON public.user_responsibilities FOR UPDATE TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());
CREATE POLICY "Only super admins remove operational responsibilities"
ON public.user_responsibilities FOR DELETE TO authenticated
USING (public.is_super_admin());

CREATE POLICY "Employees read their teams or organization teams"
ON public.teams FOR SELECT TO authenticated
USING (
  public.is_super_admin()
  OR public.has_permission('teams', 'read', 'organization')
  OR EXISTS (
    SELECT 1 FROM public.team_memberships tm
    WHERE tm.team_id = id AND tm.user_id = auth.uid()
  )
);
CREATE POLICY "Super admins create teams"
ON public.teams FOR INSERT TO authenticated
WITH CHECK (public.is_super_admin());
CREATE POLICY "Authorized managers update teams"
ON public.teams FOR UPDATE TO authenticated
USING (public.can_manage_team(id))
WITH CHECK (public.can_manage_team(id));
CREATE POLICY "Super admins delete teams"
ON public.teams FOR DELETE TO authenticated
USING (public.is_super_admin());

CREATE POLICY "Employees read team memberships within scope"
ON public.team_memberships FOR SELECT TO authenticated
USING (
  user_id = auth.uid()
  OR public.is_super_admin()
  OR public.has_permission('employees', 'read', 'organization')
  OR (public.has_permission('employees', 'read', 'team') AND public.shares_team_with(user_id))
);
CREATE POLICY "Authorized managers add team memberships"
ON public.team_memberships FOR INSERT TO authenticated
WITH CHECK (public.can_manage_team(team_id));
CREATE POLICY "Authorized managers update team memberships"
ON public.team_memberships FOR UPDATE TO authenticated
USING (public.can_manage_team(team_id))
WITH CHECK (public.can_manage_team(team_id));
CREATE POLICY "Authorized managers remove team memberships"
ON public.team_memberships FOR DELETE TO authenticated
USING (public.can_manage_team(team_id));

CREATE POLICY "Super admins read invitations"
ON public.employee_invitations FOR SELECT TO authenticated
USING (public.is_super_admin());
CREATE POLICY "Super admins create invitations"
ON public.employee_invitations FOR INSERT TO authenticated
WITH CHECK (public.is_super_admin() AND invited_by = auth.uid());
CREATE POLICY "Super admins update invitations"
ON public.employee_invitations FOR UPDATE TO authenticated
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());
CREATE POLICY "Super admins delete invitations"
ON public.employee_invitations FOR DELETE TO authenticated
USING (public.is_super_admin());

CREATE OR REPLACE FUNCTION public.guard_profile_role_fields()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF (NEW.id, NEW.email, NEW.manager_id, NEW.employment_status, NEW.job_title, NEW.department)
     IS DISTINCT FROM
     (OLD.id, OLD.email, OLD.manager_id, OLD.employment_status, OLD.job_title, OLD.department)
     AND NOT public.is_super_admin() THEN
    RAISE EXCEPTION 'Only a Super Admin can change protected employee fields.';
  END IF;
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.guard_profile_role_fields() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER protect_profile_access_fields
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.guard_profile_role_fields();