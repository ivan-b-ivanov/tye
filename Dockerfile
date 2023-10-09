
# Builder Stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder
WORKDIR /app

# Copy Directory.Build.props to the root of the container
COPY src/Directory.Build.props /Directory.Build.props

# Copy the entire source directory
COPY src/ ./src/

# Adjust the working directory to the main project
WORKDIR /app/src/tye

RUN dotnet restore
RUN dotnet publish --output /out/ --configuration Release --no-restore

RUN sed -n 's:.*<AssemblyName>\(.*\)</AssemblyName>.*:\1:p' *.csproj > __assemblyname
RUN if [ ! -s __assemblyname ]; then filename=$(ls *.csproj); echo ${filename%.*} > __assemblyname; fi

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=builder /out .

ENV PORT 5000
EXPOSE 5000

ENTRYPOINT dotnet $(cat /app/__assemblyname).dll --urls "http://*:5000"
