# CareerVeda Placement Operations ERP — Phase 1

## Outcome
Replace the template with the CareerVeda foundation: a usable, role-aware staff workspace plus a secure employee, team, and access-management base. Build Phase 1 only; leave recruitment, interviews, tasks/EOD, imports/exports, analytics, and automation for later phases.

## Work
1. **Document the blueprint** in a concise architecture reference: Phase 1 ER diagram, role/scope permissions matrix, RLS boundaries, and the complete phased roadmap.
2. **Create the Cloud foundation:** employee profiles, system roles, independent operational responsibilities, teams and memberships, and permission scopes. Generate profiles on account creation without granting roles. Add SQL helpers and row policies for self, team, organization, and administrator scopes.
3. **Secure staff accounts:** email/password only, invitation-only registration, profile-aware authentication, no automatic Super Admin/Placement Head. The first administrator remains a deliberate owner action; until assigned, staff see a clear access-pending screen rather than privileged tools.
4. **Build the Phase 1 workspace:** sign-in, role-aware dashboard, employee/team directory, and administrator-only invitations/access assignment. Confirm each write against database policies, not just hidden interface controls.
5. **Verify** migrations, permission rules, routing tests, and the primary signed-in flow; review desktop and mobile layouts.

## Acceptance
- Public visitors cannot self-register; invited staff can sign in by email/password.
- A newly created account receives a profile, but no elevated role.
- Only an assigned Super Admin can invite staff and manage system roles.
- Staff access to profiles and teams follows own/team/organization scope enforced by row policies.
- No invented employee, company, or candidate records are presented as real operational data.

## Technical details
- Use the existing TanStack Start v1 + React + Tailwind v4 setup and Lovable Cloud clients.
- Use a database trigger for profile creation and separate role, responsibility, team-membership, and role-permission records; never store roles in profile fields or user-editable auth metadata.
- Keep privileges in PostgreSQL RLS and authenticated server functions. Import the privileged client only inside a handler and after a database-backed Super Admin check.
- Apply schema through the database migration tool and seed baseline permission rows through the database data tool, not in the DDL migration.