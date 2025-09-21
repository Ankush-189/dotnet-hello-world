# =========================
# 1. Build Stage
# =========================
FROM mcr.microsoft.com/dotnet/core/sdk:2.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["hello-world-api/hello-world-api.csproj", "hello-world-api/"]
RUN dotnet restore "hello-world-api/hello-world-api.csproj"

# Copy the rest of the source code
COPY . .

# Publish the app (Release configuration)
RUN dotnet publish "hello-world-api/hello-world-api.csproj" -c Release -o /app/publish

# =========================
# 2. Runtime Stage
# =========================
FROM mcr.microsoft.com/dotnet/core/aspnet:2.0 AS runtime
WORKDIR /app

# Copy published app from build stage
COPY --from=build /app/publish .

# Expose port your app listens on
EXPOSE 9090

# Run the app
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
