# CareerVeda Placement Hub

Worked for 27s



Buddy, after analyzing your uploaded requirements, previous CRM discussions, TalentHub dashboard structure, candidate calling workflow, interview scheduling requirements, Excel imports, employee assignments, EOD reporting, and custom exports, I recommend building something bigger than a normal Placement CRM.



You should build CareerVeda Placement Operations ERP — a centralized, role-based, serverless recruitment and placement management platform.



The most important architectural decision is this:



> Every employee should have their own responsibilities, dashboard, assignments and EOD reporting, while the Placement Head should have complete visibility into the entire placement operation.



The system should connect the entire workflow, from company acquisition and candidate calling to interview scheduling, selection, offer management and final placement.



### 1\. Understanding the actual business workflow



Your requirements represent five interconnected business operations.



### CareerVeda Placement ERP



END-TO-END OPERATIONAL WORKFLOW



1\. Company & Employer Relations



Company acquisition · HR contacts · Job opportunities



2\. Candidate Management



Candidate database · Calling · WhatsApp · CV sharing · Eligibility



3\. Recruitment Operations



Shortlisting · Candidate applications · Interview coordination



4\. Interview & Placement



Booking · Scheduling · Feedback · Selection · Offers · Joining



5\. Placement Intelligence



Performance · EOD · Analytics · Reports · Custom exports



All five operations are connected through one employee assignment and permission system.



This is consistent with your original requirements for company CRM, candidate CRM, job applications, assignments, task management, dashboards, imports and exports.



### 2\. Recommended organizational roles and responsibilities



I recommend defining roles based on actual business responsibilities rather than giving everyone access to the same dashboard.



There should be two layers:



* System roles: Determine what a user is allowed to access.



* Operational responsibilities: Determine what work a user is responsible for completing.



A person can have multiple operational responsibilities if your team is small.



### A. Role hierarchy



Super Admin



Complete system ownership and configuration



Placement Head



Organization-wide placement operations



Placement Manager



Team management and performance



Operations Manager



Recruitment coordination and execution



Company Relations Executive



Candidate Calling Executive



Interview Coordinator



Placement Executive



Data & CRM Executive



Placement Analyst



Viewer / Management Viewer



Read-only access to permitted information



These are recommended operational role templates, not a claim that CareerVeda currently has all these separate employees.



### B. Detailed responsibilities



| Role                        | Primary responsibilities                                       |

| --------------------------- | -------------------------------------------------------------- |

| Super Admin                 | Users, permissions, configurations, security, complete access  |

| Placement Head              | Placement strategy, targets, team allocation, final monitoring |

| Placement Manager           | Assign work, monitor team, approve EOD, review performance     |

| Operations Manager          | Manage recruitment workflow, interviews and escalations        |

| Company Relations Executive | Contact companies, HR coordination, job opportunities          |

| Candidate Calling Executive | Candidate calls, WhatsApp, CV sharing, follow-ups              |

| Interview Coordinator       | Booking, interview slots, emails, confirmations, rescheduling  |

| Placement Executive         | Candidate-company matching, applications, placement follow-up  |

| Data & CRM Executive        | Excel imports, validation, duplicates and record maintenance   |

| Placement Analyst           | Reports, analytics, export configurations and data insights    |

| Viewer                      | Read-only access to authorized dashboards                      |



### C. Responsibilities in detail



1\. Placement Head



The Placement Head should be able to:



* See all company and candidate records.



* Assign companies and candidates to employees.



* Assign tasks to managers and teams.



* Set monthly and weekly placement targets.



* Monitor recruitment pipelines.



* Monitor interview scheduling.



* Review employee performance.



* View EOD reports.



* Approve escalations.



* Generate organization-wide reports.



2\. Placement Manager



The manager should be able to:



* Create and assign tasks.



* Assign candidates to executives.



* Allocate companies to team members.



* Monitor employee activities.



* Review daily EOD submissions.



* Approve or reject submitted work.



* Identify overdue follow-ups.



* Track booking and interview performance.



* Reassign work when necessary.



* Generate team-wise reports.



3\. Company Relations Executive



Their dashboard should focus on company acquisition.



Responsibilities:



* Discover and add new companies.



* Maintain HR and recruiter information.



* Call HR representatives.



* Send company introduction emails.



* Arrange company meetings.



* Record recruitment discussions.



* Collect job openings.



* Update vacancies and hiring status.



* Schedule company follow-ups.



4\. Candidate Calling Executive



Their dashboard should focus on candidate communication.



Responsibilities:



* Contact assigned candidates.



* Update calling status.



* Send WhatsApp messages.



* Send CV-related messages.



* Record call remarks.



* Schedule callbacks.



* Update candidate interest.



* Maintain candidate communication history.



* Share eligible candidates with placement executives.



5\. Interview Coordinator



Their dashboard should focus on scheduling and interview management.



Responsibilities:



* Receive interview booking requests.



* Coordinate available slots.



* Book interview appointments.



* Send interview emails.



* Track email responses.



* Confirm candidate availability.



* Reschedule interviews.



* Record attendance.



* Collect interview feedback.



6\. Placement Executive



Responsibilities:



* Match candidates with job requirements.



* Shortlist eligible candidates.



* Share profiles with companies.



* Track applications.



* Monitor interview outcomes.



* Coordinate offer and joining.



* Update placement records.



### 3\. The most important module: Candidate Calling & Interview Booking CRM



Your earlier requirement contained these specific fields:



* Name



* Course



* Calling Status



* WhatsApp Status



* CV Message



* CV Date



* Call Remarks



* Calling Date



* Booking Date



* Booked Date



* Booking Slot



* Email Send



* Interview Type



* Email Send Date



* Email Received Response



These should not all be stored in one candidate table.



They represent different business activities and should be separated into related database entities.



### A. Candidate master profile



| Field             | Description             |

| ----------------- | ----------------------- |

| Candidate ID      | Unique identifier       |

| Name              | Candidate name          |

| Email             | Email address           |

| Phone             | Contact number          |

| Course            | PM / BA / DA etc.       |

| Resume            | Resume document         |

| Skills            | Candidate skills        |

| Experience        | Work experience         |

| Course Completion | Completion percentage   |

| Test Score        | Assessment score        |

| Eligibility       | Eligible / Not Eligible |

| Assigned Employee | Responsible employee    |

| Candidate Status  | Overall placement stage |



### B. Candidate communication tracking



Separate activity records



| Field           | Description                       |

| --------------- | --------------------------------- |

| Candidate       | Linked candidate                  |

| Calling Status  | Connected / Not Answered / Busy   |

| Calling Date    | Actual call date                  |

| Call Remarks    | Conversation details              |

| WhatsApp Status | Sent / Delivered / Read / Replied |

| WhatsApp Date   | Message timestamp                 |

| CV Message      | Message status or template        |

| CV Date         | CV sharing timestamp              |

| Next Follow-up  | Next communication date           |

| Updated By      | Employee responsible              |



Each call or message creates a new activity record. Previous activities must never be overwritten.



### C. Interview booking management



| Field                   | Description                       |

| ----------------------- | --------------------------------- |

| Candidate               | Candidate reference               |

| Company                 | Recruiting company                |

| Job Opening             | Related position                  |

| Booking Date            | Booking request date              |

| Booked Date             | Actual confirmation date          |

| Booking Slot            | Start and end time                |

| Interview Type          | Online / Offline / Telephonic     |

| Email Send              | Sent / Not Sent                   |

| Email Send Date         | Email timestamp                   |

| Email Received Response | Pending / Confirmed / Declined    |

| Response Date           | Response timestamp                |

| Interview Status        | Scheduled / Completed / Cancelled |

| Meeting Link            | Interview URL                     |

| Assigned Coordinator    | Responsible employee              |



Important distinction: Booking request date, actual booking confirmation date, and scheduled interview date must be three separate values.



### D. Recommended candidate communication statuses



| Activity        | Status options                                                               |

| --------------- | ---------------------------------------------------------------------------- |

| Calling         | Not Called, Connected, No Answer, Busy, Callback, Interested, Not Interested |

| WhatsApp        | Not Sent, Sent, Delivered, Read, Replied, Failed                             |

| CV Message      | Draft, Sent, Viewed, Response Received                                       |

| Interview Email | Not Sent, Sent, Bounced, Response Received, Confirmed, Declined              |

| Booking         | Requested, Slot Proposed, Booked, Rescheduled, Cancelled                     |



This separation will make your reports much more accurate.



### 4\. Complete ERP module architecture



I recommend these modules in your existing TalentHub-style navigation.



CAREERVEDA



ERP architecture



OVERVIEW



Dashboard



Activity Feed



RECRUITMENT MANAGEMENT



Companies



Candidates



Jobs & Openings



Applications



Interviews & Bookings



Placements & Offers



Calling & Communication



PLACEMENT OPERATIONS



Team Management



Assignments



Tasks & Kanban



Daily EOD Reports



Follow-up Calendar



DATA & INTELLIGENCE



Top Performers



Eligibility Finder



Shortlists



Excel Import Center



Custom Data Export Center



Reports & Analytics



Audit Logs



SYSTEM



Notifications



Settings & Permissions



### What each module should do



| Module             | Core functionality                        |

| ------------------ | ----------------------------------------- |

| Dashboard          | Operational KPIs and pending activities   |

| Companies          | Employer and HR management                |

| Candidates         | Central candidate profiles                |

| Jobs & Openings    | Vacancies and requirements                |

| Applications       | Candidate-job relationships               |

| Interviews         | Booking and interview tracking            |

| Placements         | Offers, joining and placement records     |

| Calling            | Calls, WhatsApp, CV sharing               |

| Team Management    | Employees, roles, departments             |

| Assignments        | Record allocation and reassignment        |

| Tasks              | Task execution and approval               |

| EOD Reports        | Daily employee work submissions           |

| Eligibility Finder | Find candidates using eligibility filters |

| Shortlists         | Candidate shortlisting                    |

| Import Center      | Bulk Excel and CSV imports                |

| Export Center      | Custom datasets and downloads             |

| Analytics          | Team and recruitment performance          |



### 5\. Role-based EOD reporting system



This is something I would make mandatory in the ERP.



Instead of allowing everyone to submit the same generic EOD, the application should generate different EOD forms according to the employee's operational role.



### A. EOD responsibilities by role



| Role                  | EOD information                                                             |

| --------------------- | --------------------------------------------------------------------------- |

| Company Relations     | Companies contacted, HR responses, meetings, new openings, follow-ups       |

| Candidate Calling     | Calls attempted, connected, interested, WhatsApp sent, CV shared            |

| Interview Coordinator | Bookings requested, confirmed, emails sent, responses, interviews completed |

| Placement Executive   | Candidates shortlisted, applications submitted, selections, offers, joining |

| Data & CRM            | Imports, records created, records updated, duplicate issues, exports        |

| Manager               | Team progress, pending tasks, overdue tasks, reviewed EODs                  |

| Placement Head        | Overall recruitment progress, bottlenecks, team performance, escalations    |



### B. EOD workflow



* Manager creates assignments



    Defines tasks, employees, priorities and deadlines.



* Employee completes work



    Every calling, booking, update and task completion is recorded in the ERP.



* System generates EOD draft



    Automatically collects actual CRM activities and task progress.



* Employee submits EOD



    Adds achievements, blockers, pending work and tomorrow's plan.



* Manager reviews EOD



    Approves, requests clarification or rejects with remarks.



* Placement Head monitors performance



    Sees approved and pending reports across all teams.



An important rule: employees should not manually enter numbers that can already be calculated from their actual CRM activities. The ERP should generate those figures automatically.



EOD records should be immutable after submission except through an audited correction or revision workflow.



### 6\. Role and permission matrix



This is the access model I recommend implementing.



Legend: Full = complete permission within scope; Limited = assigned/team scope; View = read-only; — = no access.



| Module          | Super Admin | Head    | Manager    | Executive  | Viewer     |

| --------------- | ----------- | ------- | ---------- | ---------- | ---------- |

| Dashboard       | Full        | Full    | Team       | Own        | View       |

| Companies       | Full        | Full    | Team       | Limited    | View       |

| Candidates      | Full        | Full    | Team       | Limited    | View       |

| Jobs            | Full        | Full    | Team       | Limited    | View       |

| Applications    | Full        | Full    | Team       | Limited    | View       |

| Interviews      | Full        | Full    | Team       | Limited    | View       |

| Placements      | Full        | Full    | Team       | Limited    | View       |

| Assignments     | Full        | Full    | Team       | Own        | View       |

| Tasks           | Full        | Full    | Team       | Own        | View       |

| EOD Reports     | Full        | Full    | Team       | Own        | View       |

| Team Management | Full        | Full    | Team       | —          | View       |

| Import          | Full        | Full    | Limited    | Permission | —          |

| Export          | Full        | Full    | Permission | Permission | Permission |

| Audit Logs      | Full        | View    | Limited    | —          | —          |

| Settings        | Full        | Limited | —          | —          | —          |



This is a starting matrix. Actual permissions should be individually configurable.



For example, a Candidate Calling Executive may have permission to update candidate communication records without being allowed to edit candidate education or placement eligibility.



Never enforce these permissions only in React. Enforce them through Supabase PostgreSQL RLS and server-side authorization.



### 7\. Recommended serverless ERP architecture



Now the technical architecture.



TanStack Start + Supabase + Vercel



You were right to consider TanStack. Your ERP will have data-heavy tables, complex filters, custom exports, role-specific dashboards and extensive CRUD operations. The TanStack ecosystem fits this application very well.



### CareerVeda Serverless Architecture



Frontend



React + TypeScript + Tailwind CSS 4



shadcn/ui · Radix · Lucide



TanStack Application Layer



TanStack Start



Full-stack framework



TanStack Router



Type-safe routing



TanStack Query



Server state and caching



TanStack Table



CRM data grids



TanStack Form



Complex forms



TanStack Virtual



Large table rendering



Serverless Application Hosting



Vercel Functions



TanStack Start server functions · API endpoints · secure business operations



Supabase Backend Platform



PostgreSQL



Authentication + RLS



Storage



Realtime



Edge Functions



Cron + Queues



Persistent data and private documents



PostgreSQL · Private Storage Buckets · Database Backups



### Recommended technology stack



| Layer              | Technology                               |

| ------------------ | ---------------------------------------- |

| Framework          | TanStack Start                           |

| Routing            | TanStack Router                          |

| Data fetching      | TanStack Query                           |

| Data grids         | TanStack Table                           |

| Large datasets     | TanStack Virtual                         |

| Forms              | TanStack Form                            |

| Frontend           | React + TypeScript                       |

| Styling            | Tailwind CSS 4                           |

| Components         | shadcn/ui + Radix                        |

| Database           | Supabase PostgreSQL                      |

| Authentication     | Supabase Auth                            |

| Authorization      | RBAC + RLS                               |

| Backend operations | Start Server Functions                   |

| Background jobs    | Supabase Edge Functions + database queue |

| Scheduling         | Supabase Cron                            |

| File storage       | Supabase Storage                         |

| Excel              | SheetJS                                  |

| CSV                | Papa Parse                               |

| PDF                | jsPDF or equivalent                      |

| Analytics          | Recharts                                 |

| Hosting            | Vercel                                   |



### How the backend should actually work



Do not create one giant backend API.



Divide it into independent business services:



```text

src/

├── routes/

│   ├── dashboard/

│   ├── companies/

│   ├── candidates/

│   ├── jobs/

│   ├── applications/

│   ├── interviews/

│   ├── placements/

│   ├── calling/

│   ├── assignments/

│   ├── tasks/

│   ├── eod/

│   ├── imports/

│   ├── exports/

│   ├── reports/

│   └── settings/

│

├── components/

├── features/

├── services/

│   ├── company.service.ts

│   ├── candidate.service.ts

│   ├── calling.service.ts

│   ├── interview.service.ts

│   ├── assignment.service.ts

│   ├── task.service.ts

│   ├── eod.service.ts

│   ├── import.service.ts

│   └── export.service.ts

│

├── server/

│   ├── auth/

│   ├── permissions/

│   ├── workflows/

│   └── functions/

│

├─

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/222719a5-c837-4fe1-9534-6033fd8a2cb8).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
