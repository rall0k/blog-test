# Použijeme node:18-alpine ako základný obraz
FROM node:18-alpine AS base

WORKDIR /app

# Skopírujeme celý projekt
COPY . .

# Inštalujeme závislosti pre Nuxt
FROM base AS build-frontend
WORKDIR /app/frontend
RUN npm install --prefix ./frontend
RUN npm run build --prefix ./frontend

# Inštalujeme závislosti pre Strapi
FROM base AS build-backend
WORKDIR /app/admin
RUN npm install --prefix ./admin
RUN npm run build --prefix ./admin

# Final image pre spustenie aplikácií
FROM node:18-alpine AS final
WORKDIR /app

# Skopírujeme aplikácie z predchádzajúcich buildov
COPY --from=build-backend /app/admin /app/admin
COPY --from=build-frontend /app/frontend /app/frontend

# Exponujeme porty pre oba servery
EXPOSE 1337   # Strapi
EXPOSE 3000   # Nuxt SSR

# Spustíme oba servery naraz
CMD ["sh", "-c", "npm run start --prefix admin & npm run start --prefix frontend"]
