# Contributing

This document describes how the team works on this project.

## Branches

- `main` - Stable, integration branch. Only merged into, never committed to directly.
- `FullStack/Abdullah-Rana` - Full-stack development, primarily backend/data layer (`lib/core`, `lib/data`).
- `FrontEnd/Ahmad-Ali` - Frontend feature development (`lib/features`, UI screens and widgets).
- `Database/Abdullah-Qureshi` - Local database and persistence layer (`lib/data/local`, `lib/data/repositories`).

## Workflow

1. Pull the latest `main` before starting new work:
   ```
   git checkout main
   git pull origin main
   ```
2. Switch to your own branch and merge in the latest `main`:
   ```
   git checkout <your-branch>
   git merge main
   ```
3. Make changes, then commit with a clear, descriptive message:
   ```
   git add <files>
   git commit -m "Add step goal validation to GoalRepository"
   ```
4. Push your branch:
   ```
   git push origin <your-branch>
   ```
5. When a feature is ready, merge it into `main` (via pull request, or directly if the team agrees):
   ```
   git checkout main
   git merge <your-branch>
   git push origin main
   ```
6. After merging into `main`, update your own branch again so it stays in sync:
   ```
   git checkout <your-branch>
   git merge main
   git push origin <your-branch>
   ```

## Commit Messages

- Use the present tense and be specific: "Add streak calculation logic", not "fixed stuff".
- Keep each commit focused on one logical change.

## Code Ownership Boundaries

To avoid merge conflicts, stay within your area unless coordinating with the owner:

- `lib/core/services`, `lib/data/models`, `lib/data/repositories`, `lib/core/di` - backend/data layer
- `lib/data/local` - local persistence implementation
- `lib/features/**/presentation`, `lib/features/**/providers`, `lib/widgets` - frontend/UI

If a change requires touching another person's area, coordinate with them first.

## Local Builds

Local APK/AAB builds can be placed in the `releases/` folder for team reference. These files are not tracked in git.
