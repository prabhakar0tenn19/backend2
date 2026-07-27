# Multi-stage build for ASP.NET Core on .NET 10
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project file and restore dependencies first (better layer caching)
COPY backend2.csproj ./
RUN dotnet restore backend2.csproj

# Copy the remaining source and publish
COPY . .
RUN dotnet publish backend2.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Render provides PORT at runtime. Fallback to 10000 for local container runs.
EXPOSE 10000
COPY --from=build /app/publish .

ENTRYPOINT ["sh", "-c", "dotnet backend2.dll --urls http://0.0.0.0:${PORT:-10000}"]
