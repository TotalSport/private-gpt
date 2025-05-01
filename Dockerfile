FROM python:3.11.6-slim-bookworm AS base

RUN apt-get update && apt-get install -y git gcc build-essential && \
    pip install pipx && \
    python3 -m pipx ensurepath && \
    pipx install poetry==1.8.3

ENV PATH="/root/.local/bin:$PATH"
ENV PATH=".venv/bin/:$PATH"
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

FROM base AS dependencies
WORKDIR /home/worker/app

COPY pyproject.toml poetry.lock ./

# Указываем нужные зависимости под локальный режим
ARG POETRY_EXTRAS="ui vector-stores-qdrant llms-llama-cpp embeddings-huggingface"
RUN poetry install --no-root --extras "${POETRY_EXTRAS}"

FROM base AS app
ENV PYTHONUNBUFFERED=1
ENV PORT=8080
ENV APP_ENV=local
ENV PYTHONPATH="$PYTHONPATH:/home/worker/app/private_gpt/"
EXPOSE 8080

ARG UID=100
ARG GID=65534

RUN adduser --system --gid ${GID} --uid ${UID} --home /home/worker worker
WORKDIR /home/worker/app

RUN chown worker /home/worker/app
RUN mkdir local_data && chown worker local_data
RUN mkdir models && chown worker models

# Сюда загрузи свою .gguf модель через COPY или volume
# Пример: COPY --chown=worker models/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf models/

COPY --chown=worker --from=dependencies /home/worker/app/.venv/ .venv
COPY --chown=worker private_gpt/ private_gpt
COPY --chown=worker *.yaml .
COPY --chown=worker scripts/ scripts

USER worker

ENTRYPOINT ["poetry", "run", "python", "-m", "private_gpt"]
