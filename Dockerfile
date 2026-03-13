# syntax=docker/dockerfile:1
# ── Stage 1: build virtualenv ─────────────────────────────────────
FROM python:3.15.0a7-alpine3.23 AS builder
WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel \
 && pip install --default-timeout=100 --no-cache-dir -r requirements.txt

# ── Stage 2: runner ───────────────────────────────────────────────
FROM python:3.15.0a7-alpine3.23 AS runner
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY . .
#RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app
RUN adduser -D -u 1001 appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:3000/health')" || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
