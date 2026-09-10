# SDK versions match the repository pins. Locks are mandatory; build outside the small VPS.
FROM node:24.20.0-bookworm-slim AS web
WORKDIR /src
COPY .npmrc ./
COPY apps/web/package*.json apps/web/
WORKDIR /src/apps/web
RUN npm ci
COPY apps/web/ ./
COPY contracts/typescript/ /src/contracts/typescript/
RUN npm run build

FROM mcr.microsoft.com/dotnet/sdk:10.0.400-noble AS api
WORKDIR /src
COPY global.json Directory.Build.props ./
COPY apps/api/ apps/api/
RUN dotnet restore apps/api/src/HomeOffice.Api --locked-mode
RUN dotnet publish apps/api/src/HomeOffice.Api -c Release --no-restore -o /out

FROM mcr.microsoft.com/dotnet/aspnet:10.0.11-noble AS runtime
WORKDIR /app
COPY --from=api /out/ ./
COPY --from=web /src/apps/web/dist/ ./wwwroot/
COPY infra/pilot/healthcheck.sh ./
ENV ASPNETCORE_HTTP_PORTS=8080 DOTNET_EnableDiagnostics=0
USER 1654:1654
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=4 CMD ["bash", "/app/healthcheck.sh"]
ENTRYPOINT ["dotnet", "HomeOffice.Api.dll"]
