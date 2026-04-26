# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy csproj and restore
COPY src/sallys_collection/sallys_collection/sallys_collection.csproj src/sallys_collection/sallys_collection/
RUN dotnet restore src/sallys_collection/sallys_collection/sallys_collection.csproj

# Copy the rest of the source code
COPY . .

# Build the application
RUN dotnet publish src/sallys_collection/sallys_collection/sallys_collection.csproj -c Release -o /app/publish --no-restore

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash dotnetuser

WORKDIR /app

COPY --from=build /app/publish .

RUN chown -R dotnetuser:dotnetuser /app

USER dotnetuser

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENV PORT=8080
EXPOSE $PORT

ENTRYPOINT ["dotnet", "sallys_collection.dll"]
