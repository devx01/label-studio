# Label Studio (the real server)

The labelling server behind the API gateway: Label Studio 1.23.2 (Apache-2.0), run locally.

```bash
./start.sh            # http://127.0.0.1:8088   (LS_PORT=… to change; 8080 is often taken)
```

The first run:
- creates `.venv`: `pip install label-studio==1.23.2` (Python 3.10+; `PYTHON=python3.12 ./start.sh` to pick one)
- writes `.env`: the admin user `admin@example.com`, a random password, and an API token (`LS_ADMIN_TOKEN`)
- creates that user with that token in `data/`

`.env` and `data/` are gitignored. `data/` holds the database: tasks and annotations of footage that shows
identifiable workers, so it stays on this machine.

## Who talks to it
- **The gateway is its only API client.** It calls Label Studio with `Authorization: Token <LS_ADMIN_TOKEN>`, read
  from this `.env` (or `LABEL_STUDIO_TOKEN`).
  - It keeps one project, "Safety labelling", with every batch.
  - Pushing a batch imports its tasks; each image URL points at the gateway (`/files/batches/…`) and the pre-labels
    come along as predictions.
  - It reads tasks, saves annotations and exports through the REST API.
- **The web app never calls it.** The app embeds only Label Studio's editor (the frontend library), which loads its
  task from the gateway and submits to the gateway.
- **The UI at :8088** is for an admin on this machine: log in with the email and password in `.env` to see the
  projects, tasks and annotations the gateway stored.

Login is simplified: the gateway user `admin` / `admin` maps to this one Label Studio admin user, so every annotation
is `completed_by` it. Several users later means one Label Studio user and token per gateway user.
