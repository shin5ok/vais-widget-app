FROM python:3.12.3-slim

WORKDIR /app

COPY . .
RUN pip install --no-cache-dir poetry \
  && poetry config virtualenvs.in-project true
RUN poetry install


# USER nobody
ENV PYTHONUNBUFFERED=on

CMD ["poetry", "run", "uvicorn", "--host=0.0.0.0", "--port=8080", "--workers=8", "main:app"]
