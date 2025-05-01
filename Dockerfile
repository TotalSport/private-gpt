FROM python:3.11-slim

# Установка Poetry напрямую
RUN apt-get update && \
    apt-get install -y git gcc curl build-essential && \
    pip install poetry==1.8.3

ENV POETRY_VIRTUALENVS_IN_PROJECT=true

WORKDIR /app

# Копируем конфиг-файлы
COPY pyproject.toml poetry.lock ./

# Устанавливаем зависимости
RUN poetry install --no-interaction --no-ansi --extras "ui vector-stores-qdrant llms-llama-cpp embeddings-huggingface"

# Копируем весь проект
COPY . .

# Скачиваем модель при сборке контейнера
RUN mkdir -p models && \
    curl -L -o models/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf \
    https://huggingface.co/TheBloke/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf

EXPOSE 8080

CMD ["poetry", "run", "python", "-m", "private_gpt"]
