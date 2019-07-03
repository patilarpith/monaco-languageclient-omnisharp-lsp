FROM node:8.16.0-stretch-slim

# monaco-languageclient
WORKDIR /app
COPY example/package.json package.json
COPY example/tsconfig.json tsconfig.json
COPY example/webpack.config.js webpack.config.js
COPY example/src src
RUN npm install && npm run build

# Omnisharp
ENV OMNISHARP_VERSION 1.33.0
ENV DOTNET_SDK_VERSION 2.2.300
RUN curl -L -o omnisharp.tar.gz https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v$OMNISHARP_VERSION/omnisharp-linux-x64.tar.gz
RUN curl -L -o dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz
RUN mkdir -p /opt/dotnet && tar -zxf dotnet.tar.gz -C /opt/dotnet
RUN mkdir -p /opt/omnisharp && tar -zxf omnisharp.tar.gz -C /opt/omnisharp

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu57 \
        liblttng-ust0 \
        libssl1.0.2 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /opt/dotnet/dotnet /usr/bin/dotnet
ENV DOTNET_RUNNING_IN_CONTAINER=true \
	NUGET_XMLDOC_MODE=skip \
	DOTNET_USE_POLLING_FILE_WATCHER=true
# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet help

COPY csharp-workspace/Solution.csproj /workspace
COPY csharp-workspace/Solution.cs /workspace
COPY csharp-workspace/omnisharp.json $HOME/.omnisharp/

# Entrypoint
CMD npm run start:ext
