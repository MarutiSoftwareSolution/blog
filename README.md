# Blogfront

A modern, open-source blog engine built with .NET and C#. Designed for performance, simplicity, and flexibility, Blogfront empowers creators to manage their content without fighting with complex configuration.

## Features

- **Clean & Fast**: Lightweight and built for speed.
- **Role-Based Access Control**: Built-in Admin, Editor, and Author roles.
- **Rich Content Creation**: Easily draft, schedule, and publish posts.
- **Customizable**: Built with extensibility in mind.

---

## 🚀 Getting Started

To get the core logic of Blogfront running locally:

### Prerequisites
- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) or later
- SQL Server (or SQLite based on your configuration)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/MarutiSoftwareSolution/blog.git
   cd blog
   ```

2. **Restore dependencies:**
   ```bash
   dotnet restore Blog.slnx
   ```

3. **Configure the Environment:**
   Copy `appsettings.example.json` to `appsettings.json` inside the `Blog.Web` directory and configure your Database connection string:
   ```bash
   cd Blog.Web
   cp appsettings.example.json appsettings.json
   ```

4. **Initialize the Database:**
   Blogfront uses Entity Framework Core and can automatically configure the database on first run:
   ```bash
   dotnet watch run
   ```
   *(Note: The application is designed to auto-apply migrations and seed initial roles on the very first run!)*

   **Alternative (Manual SQL Setup):**
   If you prefer to manually set up your target database or are attaching Blogfront to a separate container, you can execute the raw standard SQL found in the root directory:
   ```bash
   # Use your preferred SQL client to run init.sql against your database
   ```

---

## 📖 Walkthrough: Core Architecture & Flows

Blogfront is designed with a clear separation of concerns, ensuring that the content creation experience is smooth while maintaining strict security and flexibility. Here's how the core flows work:

### 1. User Authentication & Security

Blogfront uses a robust, cookie-based authentication system backed by industry-standard hashing:

- **First Run Claim**: On the first launch, if no users exist, the application redirects to the `/register` page. The first user to register is automatically granted the **Admin** role, which seeds the initial RBAC (Role-Based Access Control) permissions.
- **Data Security**: Passwords are never stored in plaintext. Blogfront uses PBKDF2 with SHA-256 (100,000 iterations) and a unique 16-byte salt per user.
- **Session Management**: Upon successful login, a Claims Principal is constructed including the user's ID, Email, Display Name, Role, and granular Permissions. This is signed into a secure, HTTP-only cookie valid for 7 days.
- **Profile Management**: Users can update their avatars, bios, and securely change their passwords from their profile workspace.

### 2. Post Creation & Publishing

The content creation flow is built for speed and reliability:

- **Rich Editing Interface**: Users navigate to `/admin/posts/create` to land on the editor. They can dynamically assign categories and tags retrieved based on their user ID.
- **Resilient Auto-Save**: To prevent data loss, the editor uses an HTMX-powered endpoint (`/admin/posts/autosave/{id}`) that continuously saves content in the background while the author writes.
- **Publishing & Permissions**:
  - When submitting a post, a user can choose to save it as a **Draft** or **Publish** it.
  - If a user lacks the `posts.publish` permission, the system safely intercepts the submission and saves it as a draft instead.
- **Scheduling Engine**: If a `ScheduledAt` date is set in the future, the post enters a `Scheduled` state, becoming visible to the public only when that date is reached.
- **Transaction Safety**: The `PostService` wraps post data, category mappings, and tag creation inside atomic SQL transactions, ensuring no orphaned data relationships.

### 3. Media Management

Blogfront includes a built-in media library to handle uploads securely:

- **Secure Uploads**: The `MediaController` restricts uploads to explicitly permitted MIME types (images, select document formats, and web-ready videos) and enforces a 10MB file size limit.
- **Organized Storage**: Uploads are automatically sorted into safe directories organized by year and month (e.g., `/uploads/images/2026-03/`) to prevent folder bloat. File names are strictly randomized using hashes to prevent directory traversal attacks.
- **Media API**: The editor integrates with a paginated JSON API (`/admin/media/api`) allowing users to easily browse and insert previously uploaded media into their posts without leaving the writing flow.

### 4. Theme & Layout Customization

Blogfront offers powerful, zero-code aesthetic customization:

- **Dynamic Theming**: The `ThemeSettingsController` provides an engine to customize CSS variables dynamically. Users can change primary colors, typography, borders, and backgrounds right from the dashboard.
- **Curated Presets**: The system comes pre-seeded with beautiful, fully accessible color palettes (e.g., "Ocean Breeze", "Midnight Blue", "Obsidian Rose"). 
- **Composable Layouts**: Beyond colors, users can select different structural layouts ("Magazine", "Minimal", "Grid") for the navbar, footer, and individual post cards independently. These settings are persisted in the database and injected directly into the frontend views.

---

