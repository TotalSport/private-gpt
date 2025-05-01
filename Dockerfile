FROM python:3.11-slim

# Установка Poetry в стандартное место
RUN pip install poetry

WORKDIR /app

COPY . .

RUN poetry install --no-interaction --no-ansi

EXPOSE 8080

# Явно укажем ENTRYPOINT через CMD
ENTRYPOINT ["poetry", "run", "python", "-m", "private_gpt"]

