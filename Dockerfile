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

# Expose port and set entrypoint
EXPOSE 80
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
