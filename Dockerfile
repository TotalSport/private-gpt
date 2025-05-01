FROM python:3.11-slim

# Установка Poetry напрямую
RUN apt-get update && \
    apt-get install -y git gcc build-essential && \
    pip install poetry==1.8.3

ENV POETRY_VIRTUALENVS_IN_PROJECT=true

WORKDIR /app

# Копируем конфиг-файлы
COPY pyproject.toml poetry.lock ./

# Устанавливаем нужные зависимости (без pipx)
RUN poetry install --no-interaction --no-ansi --extras "ui vector-stores-qdrant llms-llama-cpp embeddings-huggingface"

# Копируем весь проект
COPY . .

EXPOSE 8080

CMD ["poetry", "run", "python", "-m", "private_gpt"]
