FROM python:3.11-slim

RUN pip install poetry

WORKDIR /app

COPY . .

RUN poetry install --no-interaction --no-ansi --extras "ui"

EXPOSE 8080

ENTRYPOINT ["poetry", "run", "python", "-m", "private_gpt"]
