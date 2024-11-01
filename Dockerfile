FROM oven/bun:1 AS base
RUN apt-get update && apt-get install -y wget


FROM base AS deps
WORKDIR /app
COPY package.json .
COPY bun.lockb .
RUN bun install --frozen-lockfile


FROM deps AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN bun build ./src/index.ts --outfile index.js


FROM base AS start
WORKDIR /app
COPY --from=builder /app/index.js ./index.js
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000
USER bun
EXPOSE 3000
CMD ["bun", "run", "index.js"]