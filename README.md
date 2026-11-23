# SkinGenie

SkinGenie is a Flutter web and mobile client with a Flask API for personalised skincare product recommendations. It matches a user's skin type and concerns to ingredient terms, then filters products by rating, routine, price range, and gender. MongoDB stores the product catalogue, user accounts, and recommendation history. An optional OpenRouter integration powers the skincare chat assistant.

## Project layout

- `frontend/web_application/` — Flutter application.
- `backend/services/system_new.py` — Flask API used by the app.
- `backend/services/init_db.py` — loads the product catalogue CSV into MongoDB.
- `preprocessed_skincare_products.csv` — source product catalogue used for the database import.
- `render.yaml` — Render deployment blueprint for the API.
- `frontend/web_application/vercel.json` and `.github/workflows/deploy-frontend-vercel.yml` — Vercel static frontend routing and CI deployment.

Visit https://project-o2zja.vercel.app/ to use the recommendation engine!
