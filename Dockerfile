# Build stage
FROM mcr.microsoft.com/dotnet/sdk:2.1 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["hello-world-api/hello-world-api.csproj", "hello-world-api/"]
RUN dotnet restore "hello-world-api/hello-world-api.csproj"

# Copy all source files
COPY . .

# Publish application
RUN dotnet publish "hello-world-api/hello-world-api.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:2.1 AS runtime
WORKDIR /app

# Copy published files from build stage
COPY --from=build /app/publish .

# Ensure the app listens on all network interfaces
ENV ASPNETCORE_URLS=http://+:80

# Expose port 80
EXPOSE 80

# Add healthcheck (verifies app responds on port 80)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:80/ || exit 1

# Run the application
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
