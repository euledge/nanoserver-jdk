ARG NANOSERVER_VERSION=lts-nanoserver-1809
FROM mcr.microsoft.com/powershell:${NANOSERVER_VERSION} AS  build

LABEL \
    org.label-schema.name="NanoServer.Java.OpenJDK" \
    org.label-schema.description="This image is an OpenJDK (Java) from Azul Systems® Zulu on NanoServer image." \
    org.label-schema.version="1.0.0" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vendor="Hitoshi Kuroyanagi" \
    org.label-schema.url="https://www.azul.com/" \
    org.label-schema.maintainer.name="euledge" \
    org.label-schema.vcs-url="https://github.com/euledge/nanoserver-jdk"\
    org.label-schema.docker.cmd="docker run --name $CONTAINER -t -d nanoserver.java.openjdk:latest" \
    org.label-schema.docker.cmd.test="docker exec $CONTAINER java -version" \
    org.label-schema.docker.cmd.debug="docker exec -it $CONTAINER powershell" \
    org.label-schema.docker.docker.cmd.help="docker exec $CONTAINER java -help" \
    org.label-schema.docker.params="OPENJDK_VERSION=version number"

ARG OPENJDK_VERSION=zulu8.54.0.21-ca-jdk8.0.292-win_x64

SHELL ["pwsh", "-Command"]

RUN \
    if(!(Test-Path -Path 'C:\Temp')) \
    { \
    New-Item \
    -Path 'C:\Temp' \
    -ItemType Directory \
    -Verbose | Out-Null ; \
    } ; \
    \
    Invoke-WebRequest \
    -Uri "https://cdn.azul.com/zulu/bin/$ENV:OPENJDK_VERSION.zip" \
    -OutFile "C:\Temp\$ENV:OPENJDK_VERSION.zip" \
    -UseBasicParsing \
    -Verbose ; \
    \
    Expand-Archive \
    -Path "C:\Temp\$ENV:OPENJDK_VERSION.zip" \
    -DestinationPath 'C:\Program Files\Zulu' \
    -Verbose ;

USER ContainerAdministrator
RUN  Set-ItemProperty \
    -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' \
    -Name 'Path' \
    -Value $($ENV:Path + 'C:\Program Files\Zulu\' + $ENV:OPENJDK_VERSION + '\bin') \
    -Verbose ; \
    \
    Set-ItemProperty \
    -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' \
    -Name 'JAVA_HOME' \
    -Value $('C:\Program Files\Zulu\' + $ENV:OPENJDK_VERSION) \
    -Verbose ;
USER ContainerUser

# Test application
RUN java \
    -version
RUN javac \
    -version

# Remove temporary items from the build image
RUN \
    Remove-Item \
    -Path 'C:\Temp' \
    -Recurse \
    -Verbose ;
