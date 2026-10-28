# Image SWI-Prolog à version fixe (contient les bibliothèques, dont http/json)
FROM swipl:9.2.9

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 boussole

WORKDIR /app
COPY requirements.txt .
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt
ENV PATH="/opt/venv/bin:$PATH" PYTHONDONTWRITEBYTECODE=1

COPY prolog ./prolog
COPY api ./api
COPY web ./web

# Vérifie au build que la base de règles se charge et que les tests Prolog passent
RUN swipl -q -g run_tests -t halt prolog/tests.pl

USER boussole
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python3 -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/api/sante', timeout=4).status == 200 else 1)"

# $PORT est fourni par Render/Railway ; 8000 par défaut en local
CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
