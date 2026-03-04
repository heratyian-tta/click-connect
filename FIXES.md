# FIXES.md — Prioritized Improvement Plan

## P0 — Critical (Security / Architecture / Broken Patterns)

These issues must be resolved before the project can be considered safe or functional.

---

### P0-1: Restore CSRF Protection

**File:** `app/controllers/application_controller.rb`

**Problem:** `skip_forgery_protection` on line 2 disables Rails' CSRF protection for every controller and every action in the application. This means any malicious website can submit forms on behalf of authenticated users.

**Suggested solution:** Remove the line entirely. Rails enables CSRF protection by default. If certain API endpoints need to be exempt, use `protect_from_forgery with: :null_session` scoped only to those controllers.

```ruby
# Before (INSECURE):
class ApplicationController < ActionController::Base
  skip_forgery_protection
  ...
end

# After:
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  ...
end
```

---

### P0-2: Add Authorization Framework

**Files:** `app/controllers/projects_controller.rb`, `app/controllers/skills_controller.rb`, `app/controllers/profiles_controller.rb`

**Problem:** No authorization checks exist. Any authenticated user can edit or destroy any project, any skill, and view any profile. There is no role-based access control, no ownership checking, and no gem like Pundit or CanCanCan configured.

**Suggested solution:** Add Pundit.

1. Add to `Gemfile`: `gem "pundit"`
2. Include in ApplicationController: `include Pundit::Authorization`
3. Create policies:

```ruby
# app/policies/project_policy.rb
class ProjectPolicy < ApplicationPolicy
  def update?
    record.users.include?(user)  # only members can edit
  end

  def destroy?
    record.users.include?(user)
  end
end
```

4. In controllers, authorize before sensitive actions:
```ruby
def update
  authorize @project
  ...
end
```

---

### P0-3: Fix the Dashboard Layout — Remove Standalone HTML Document

**File:** `app/views/dashboard/index.html.erb`

**Problem:** The dashboard view contains its own `<!DOCTYPE html>`, `<html>`, `<head>`, `<body>` tags, completely bypassing `application.html.erb`. This means:
- The navbar and footer are not shown (different custom elements are used instead)
- Breadcrumbs from the layout are not rendered
- The `csrf_meta_tags` from the layout are not present
- The viewport meta tag from the layout is overridden
- Assets loaded in the layout are duplicated
- Flash messages cannot appear

**Suggested solution:** Remove lines 1–11 (`<!DOCTYPE html>` through `<body>`) and lines 126–127 (`</body></html>`). Move any unique `<head>` content (Font Awesome CDN link) into a `content_for :head` block.

```erb
<%# app/views/dashboard/index.html.erb %>
<% content_for :head do %>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<% end %>

<div class="app-container">
  <!-- existing dashboard content, WITHOUT the html/head/body wrappers -->
</div>
```

---

### P0-4: Fix the Recursive Flash Partial

**File:** `app/views/shared/_flash.html.erb`

**Problem:** Line 1 calls `render partial: "shared/flash"` — the partial calls itself. This creates infinite recursion and would raise `SystemStackError` if the partial were ever rendered.

Additionally, `application.html.erb` never renders the flash partial, so flash messages (e.g., "Project was successfully created.") never appear to users.

**Suggested solution:**

Step 1 — Remove the recursive call from `_flash.html.erb`:
```erb
<%# app/views/shared/_flash.html.erb — REMOVE line 1 %>
<% if notice.present? %>
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <%= notice %>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
<% end %>

<% if alert.present? %>
  <div class="alert alert-warning alert-dismissible fade show" role="alert">
    <%= alert %>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
<% end %>
```

Step 2 — Render the flash partial in the layout:
```erb
<%# app/views/layouts/application.html.erb %>
<div class="container">
  <%= render partial: "shared/flash" %>
  <%= render partial: "shared/breadcrumbs" %>
  <%= yield %>
</div>
```

Note: Bootstrap's dismissible alerts require Bootstrap JS, which is not currently loaded. Either load Bootstrap JS or use Stimulus for dismiss behavior.

---

### P0-5: Fix Duplicate `show` Method in SkillsController

**File:** `app/controllers/skills_controller.rb`

**Problem:** `show` is defined twice — once at lines 10–12 (empty) and again at lines 43–50 (sets breadcrumbs). Ruby silently discards the first definition, but the duplicate is a functional bug and misleads anyone reading the code.

**Suggested solution:** Remove the first empty `show` definition (lines 10–12) and keep only the second:

```ruby
# Keep only this one:
def show
  @breadcrumbs = [
    { content: "Skills", href: skills_path },
    { content: "Name: #{@skill.name}" },
  ]
end
```

---

### P0-6: Fix Duplicate `belongs_to` Declarations in UserProject

**File:** `app/models/user_project.rb`

**Problem:** Lines 22–23 declare `belongs_to :user` and `belongs_to :project`. Lines 25–26 re-declare them with explicit `required:`, `class_name:`, and `foreign_key:` options. Rails' `belongs_to` is `required: true` by default in Rails 5+. The duplicate declarations silently override the first pair.

**Suggested solution:** Remove lines 22–23 and keep only the explicit declarations, or remove the duplicates and rely on the simpler form:

```ruby
class UserProject < ApplicationRecord
  belongs_to :user
  belongs_to :project
end
```

---

## P1 — Important (Maintainability / Convention / Cleanliness)

---

### P1-1: Replace Template Module Name

**File:** `config/application.rb`

**Problem:** Line 21: `module Rails8Template` — the Rails scaffold placeholder was never updated to the project name.

**Suggested solution:**
```ruby
module ClickConnect
  class Application < Rails::Application
```

Also update `config/environment.rb` and any other references.

---

### P1-2: Add User Model Validations

**File:** `app/models/user.rb`

**Problem:** `first_name`, `last_name`, and `bio` are all nullable with no application-level validation. Users can register with blank names, breaking the `full_name` method and the dashboard welcome message.

**Suggested solution:**
```ruby
validates :first_name, presence: true
validates :last_name, presence: true
```

---

### P1-3: Write the README

**File:** `README.md`

**Problem:** The README is 7 lines of unmodified template content. A new developer has no instructions for running the project.

**Suggested solution:** At minimum, the README should include:
- Project name and 1-line description
- Tech stack (Rails 8, PostgreSQL, Devise, Ransack, Kaminari, Pico CSS)
- Prerequisites (Ruby version, PostgreSQL)
- Setup steps:
  ```bash
  bundle install
  cp .env.example .env   # fill in values
  rails db:create db:migrate db:seed
  rails server
  ```
- Required environment variables (Rollbar token, etc.)
- Contributing guidelines and branch naming convention

---

### P1-4: Enable CI and Fix Tests

**Files:** `.github/workflows/ci.yml`, `spec/`

**Problem:** All CI jobs are commented out. The only test is `expect(1).to eq(1)`.

**Suggested solution:**

Step 1 — Uncomment the CI jobs in `.github/workflows/ci.yml` (scan_ruby, scan_js, lint at minimum). Add a test runner job.

Step 2 — Add meaningful specs:
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  it { should have_many(:user_skills) }
  it { should have_many(:skills).through(:user_skills) }
  it { should validate_presence_of(:first_name) }
end

# spec/models/project_spec.rb
RSpec.describe Project, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
end
```

---

### P1-5: Remove Dead Route `users_profiles`

**File:** `config/routes.rb`

**Problem:** Line 11: `resources :users_profiles` — no `UserProfilesController` exists. This generates 7 routes that all 404.

**Suggested solution:** Remove line 11 entirely.

---

### P1-6: Remove Unused `@projects` Assignment in `projects#show`

**File:** `app/controllers/projects_controller.rb`

**Problem:** Line 12: `@projects = Project.all` is assigned in the `show` action but never used in the `show` view. This is an unnecessary database query on every project show page.

**Suggested solution:** Remove line 12:
```ruby
def show
  # @projects = Project.all  ← remove this
  @breadcrumbs = [
    { content: "Projects", href: projects_path },
    { content: @project.title, href: project_path(@project) }
  ]
end
```

---

### P1-7: Remove Orphaned TODO Comment

**File:** `app/views/skills/index.html.erb`

**Problem:** Line 17: `<%# TODO: Add a search bar to filter skills by name. %>` — the search bar was already implemented on lines 4–15 above it.

**Suggested solution:** Delete line 17.

---

### P1-8: Remove Leftover Scaffold Comment in Routes

**File:** `config/routes.rb`

**Problem:** Lines 19–20 contain the default scaffold placeholder comment:
```ruby
# This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
# get("/your_first_screen", { :controller => "pages", :action => "first" })
```

**Suggested solution:** Delete these lines.

---

### P1-9: Add Authentication to Missing Controllers

**Files:** `app/controllers/projects_controller.rb`, `app/controllers/skills_controller.rb`, `app/controllers/profiles_controller.rb`

**Problem:** Only `DashboardController` has `before_action :authenticate_user!`. Projects, Skills, and Profiles are accessible to unauthenticated users.

**Suggested solution:** Either add `before_action :authenticate_user!` to each controller, or add it to `ApplicationController` with `skip_before_action` for public pages:

```ruby
# app/controllers/application_controller.rb
before_action :authenticate_user!
```

```ruby
# app/controllers/pages_controller.rb
skip_before_action :authenticate_user!, only: [:home]
```

---

### P1-10: Fix Pagination in ProfilesController#show

**File:** `app/controllers/profiles_controller.rb`

**Problem:** Line 15: `@users = User.page(params[:page]).per(20)` in the `show` action. The `show` action displays a single user profile — it should never load all users.

**Suggested solution:** Remove the `@users` assignment from `show` entirely. Only `index` needs pagination:

```ruby
def show
  @breadcrumbs = [
    { content: "Profiles", href: profiles_path },
    { content: @user.full_name, href: profile_path(@user) },
  ]
end
```

---

## P2 — Polish / UX / Enhancements

---

### P2-1: Move Inline Styles in Dashboard to CSS

**File:** `app/views/dashboard/index.html.erb`

**Problem:** Lines 56, 66, 70–87, 90, 104 contain inline `style=""` attributes. Inline styles cannot be overridden by CSS frameworks and are difficult to maintain.

**Suggested solution:** Move inline styles into `dashboard.css` using class names. Example:

```erb
<!-- Before -->
<div style="display: flex; flex-direction: column; gap: 10px;">

<!-- After -->
<div class="projects-list">
```

```css
/* dashboard.css */
.projects-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
```

---

### P2-2: Make Skill Bar Percentages Data-Driven

**File:** `app/views/dashboard/index.html.erb`

**Problem:** Line 49: `width: <%= [45, 55, 70, 80, 90][index % 5] %>%` — hardcoded percentages. The bars convey no real information about skill levels.

**Suggested solution:** Either remove the bars (if skill proficiency levels are not tracked), or add a `proficiency` integer field to `user_skills` and display that:

```ruby
# db/migrate/..._add_proficiency_to_user_skills.rb
add_column :user_skills, :proficiency, :integer, default: 50
```

---

### P2-3: Replace `picsum.photos` Profile Images with Real Uploads

**File:** `app/models/user.rb`

**Problem:** Lines 41–43: Profile images are sourced from `https://picsum.photos/200/300?random=#{id}` — random stock photos that change on each request and have no relation to the actual user.

**Suggested solution:** Use `carrierwave` (already in Gemfile) to add a real avatar upload:
1. Generate an uploader: `rails generate uploader Avatar`
2. Add `avatar` column to users
3. Mount uploader in `User`: `mount_uploader :avatar, AvatarUploader`
4. Use a fallback to a placeholder only if no avatar is set

---

### P2-4: Add Composite Unique Index for Join Tables

**File:** `db/schema.rb`, `db/migrate/`

**Problem:** `user_skills` and `user_projects` have no composite unique constraint. A user can be associated with the same skill or project multiple times.

**Suggested solution:**
```ruby
# Migration
add_index :user_skills, [:user_id, :skill_id], unique: true
add_index :user_projects, [:user_id, :project_id], unique: true
```

```ruby
# app/models/user_skill.rb
validates :skill_id, uniqueness: { scope: :user_id }
```

---

### P2-5: Add Semantic HTML to Application Layout

**File:** `app/views/layouts/application.html.erb`

**Problem:** The main content area is wrapped in `<div class="container">` rather than `<main>`. This misses a semantic HTML opportunity and slightly impacts accessibility.

**Suggested solution:**
```erb
<main class="container">
  <%= render partial: "shared/flash" %>
  <%= render partial: "shared/breadcrumbs" %>
  <%= yield %>
</main>
```

---

### P2-6: Add Form Validation to Key Forms

**Files:** `app/views/projects/_form.html.erb`, `app/views/devise/registrations/new.html.erb`

**Problem:** No `required` attributes or client-side validation patterns on form fields. Users receive no feedback until after form submission.

**Suggested solution:** Add HTML5 validation attributes:
```erb
<%= f.text_field :title, required: true, minlength: 3 %>
<%= f.text_area :description, required: true %>
```

---

### P2-7: Add `alt` Tags to Profile Images

**File:** `app/views/profiles/_profile.html.erb`

**Problem:** Profile images rendered in the profile partial do not have `alt` text, failing basic accessibility requirements.

**Suggested solution:**
```erb
<%= image_tag user.profile_image_url, alt: "#{user.full_name} profile photo" %>
```

---

### P2-8: Enable and Configure Turbo

**File:** `app/javascript/application.js`

**Problem:** `Turbo.session.drive = false` disables Turbo Drive. Rails 8 ships with Turbo enabled by default for good reason — it provides SPA-like navigation without the overhead of a full JS framework.

**Suggested solution:** Remove that line, test for any pages that break with Turbo enabled (often pages that rely on full page reloads for reinitializing third-party scripts), and fix them using `data-turbo="false"` on specific links if needed.

---

### P2-9: Complete the ERD and Add to README

**File:** `README.md`

**Problem:** `rails-erd` and `.erdconfig` are configured but the output ERD is not in the repository or linked from the README. The `.erdconfig` excludes SolidQueue/SolidCache tables (good) but the diagram is not accessible to reviewers.

**Suggested solution:**
1. Run `rails erd` to generate `erd.pdf` or `erd.png`
2. Commit the image to the repo
3. Reference it in the README: `![ERD](erd.png)`

---

### P2-10: Implement the `ai-chat` Gem or Remove It

**File:** `Gemfile`

**Problem:** `gem "ai-chat", "~> 0.5.4"` is installed but not used anywhere in the application. Dead dependencies increase bundle size and create a confusing impression that AI features exist.

**Suggested solution:** Either:
- Remove `gem "ai-chat"` from the Gemfile if no AI feature is planned, or
- Implement a basic AI feature (e.g., a skill description assistant, a project suggestion engine) and count it toward the Ambitious Features score.
