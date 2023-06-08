FROM amazon/aws-lambda-dotnet:6 AS base
  
FROM mcr.microsoft.com/dotnet/sdk:6.0 as build  
WORKDIR /src  
COPY ["AWSDockerLambda.csproj", "base/"]  
RUN dotnet restore "base/AWSDockerLambda.csproj"  
  
WORKDIR "/src"  
COPY . .  
RUN dotnet build "AWSDockerLambda.csproj" --configuration Release --output /app/build  
  
FROM build AS publish  
RUN dotnet publish "AWSDockerLambda.csproj" \  
            --configuration Release \
            --framework net6.0 \
            --self-contained false \   
            --output /app/publish \
            --runtime linux-x64
  
FROM base AS final  
WORKDIR /var/task  
COPY --from=publish /app/publish .  
CMD ["AWSDockerLambda::AWSDockerLambda.Function::FunctionHandler"]