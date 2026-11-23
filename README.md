# SkinGenie

SkinGenie is a Flutter web and mobile client with a Flask API for personalised skincare product recommendations. It matches a user's skin type and concerns to ingredient terms, then filters products by rating, routine, price range, and gender. MongoDB stores the product catalogue, user accounts, and recommendation history. An optional OpenRouter integration powers the skincare chat assistant.

## Project layout

- `frontend/web_application/` — Flutter application.
- `backend/services/system_new.py` — Flask API used by the app.
- `backend/services/init_db.py` — loads the product catalogue CSV into MongoDB.
- `preprocessed_skincare_products.csv` — source product catalogue used for the database import.
- `render.yaml` — Render deployment blueprint for the API.
- `frontend/web_application/vercel.json` and `.github/workflows/deploy-frontend-vercel.yml` — Vercel static frontend routing and CI deployment.

## Run locally

1. Install Python 3.11, Flutter, and MongoDB (or use a MongoDB Atlas database).
2. Create `backend/services/.env` based on `backend/services/.env.example`. Set `MONGO_URI` and a long random `SECRET_KEY`. `OPENROUTER_API_KEY` is optional and only needed for chat.
3. From the repository root, load the catalogue once with `python backend/services/init_db.py`.
4. Start the API from the repository root with `python -m backend.services.system_new`.
5. In another terminal, run `cd frontend/web_application`, `flutter pub get`, then `flutter run -d chrome`. Local builds use `http://127.0.0.1:5000` by default.

## Deploy

The recommended setup serves the Flutter static site from Vercel and runs the Flask API as a long-lived Render web service. MongoDB Atlas remains the database. The API uses pandas and scikit-learn and includes an optional background price updater, so keeping it on a persistent Python service avoids forcing it into short-lived serverless functions.

### 1. Prepare MongoDB and credentials

- Create a MongoDB database and a database user. Allow connections from the API host in the Atlas network access settings.
- Generate a new random JWT `SECRET_KEY` and create an OpenRouter API key if chat is needed.
- The repository previously contained database and OpenRouter credentials in source. Rotate any credentials that were active; moving a key to environment variables does not remove it from earlier Git history.

### 2. Deploy the API to Render

- Push this repository to a Git provider and create a Render Blueprint from it using `render.yaml`.
- Set the `MONGO_URI` and `OPENROUTER_API_KEY` environment values in the Render service. Render generates `SECRET_KEY` from the blueprint. `OPENROUTER_API_KEY` can be left unset when chat is not needed.
- After the service is created, set `CORS_ORIGINS` to the exact Vercel production origin, such as `https://skingenie.example.com` (no trailing slash). Add preview origins only if you need them.
- Load the product catalogue once by running `python backend/services/init_db.py` in a shell with the Render service's `MONGO_URI` available. The API returns a helpful `503` for recommendations until the catalogue is loaded.
- Confirm `https://<your-render-service>.onrender.com/health` returns `{"status":"ok"}`.

### 3. Deploy the Flutter site to Vercel

The included GitHub Actions workflow builds Flutter web (Vercel does not compile this Flutter app itself) and uploads the static build to Vercel using the Build Output API.

- Create a Vercel project for the frontend and note its project ID and team/account ID.
- Add GitHub repository secrets `VERCEL_TOKEN`, `VERCEL_ORG_ID`, and `VERCEL_PROJECT_ID`.
- Add the GitHub Actions variable `API_BASE_URL` with the Render API origin, for example `https://skingenie-api.onrender.com` (no trailing slash).
- Push to the `main` branch or run the `Deploy Flutter web to Vercel` workflow manually. The Vercel project serves the Flutter app and rewrites app routes to `index.html`.
- Set the Vercel production origin in Render's `CORS_ORIGINS` after the first deployment.

The Flutter API URL is embedded at build time with `--dart-define=API_BASE_URL=...`. It is public client configuration and must contain only the API origin; database and model API credentials belong on the backend.

## API overview

- `POST /register`, `POST /login` — create an account and obtain a JWT.
- `GET /check-auth` — validate a JWT.
- `POST /recommend` — return primary and alternate product recommendations.
- `GET /history`, `POST /history` — retrieve or save recommendation history (JWT required).
- `POST /ask` — request a chat reply (requires `OPENROUTER_API_KEY`).
- `GET /health` — API and MongoDB health check.

The price updater is disabled by default in production. Set `ENABLE_PRICE_SCHEDULER=true` only on a single persistent API instance if scheduled price scraping is desired.
