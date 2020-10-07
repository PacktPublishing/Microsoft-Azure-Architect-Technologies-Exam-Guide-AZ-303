FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-stretch-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-stretch AS build
WORKDIR /src
COPY ["PacktACIApp/PacktACIApp.csproj", "PacktACIApp/"]
RUN dotnet restore "PacktACIApp/PacktACIApp.csproj"
COPY . .
WORKDIR "/src/PacktACIApp"
RUN dotnet build "PacktACIApp.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "PacktACIApp.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PacktACIApp.dll"]