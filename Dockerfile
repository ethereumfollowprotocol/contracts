# syntax=docker/dockerfile:1
FROM oven/bun:latest as setup

RUN apt-get update \
  && apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    tree \
  && rm -rf /var/lib/apt/lists/*

# install nodejs
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# install foundryup
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="${PATH}:/root/.foundry/bin"
RUN foundryup --version nightly-6d7cceafdcbdb5e48c128a5b32cb7267498f4674

WORKDIR /usr/src/app

# install project dependencies
COPY bun.lockb package.json ./
RUN bun install --production --frozen-lockfile

# copy the rest of the project
COPY . .

RUN forge install

RUN forge build
