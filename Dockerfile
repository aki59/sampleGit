FROM adoptjdk11

RUN ls -latr



RUN /usr/lib/jvm/java-11-openjdk/bin/jlink --output /jvm --no-header-files --no-man-pages --compress=2 \
--strip-debug --add-modules java.base,java.desktop,\
java.instrument,java.logging,java.management,java.management.rmi,\
java.naming,java.prefs,java.rmi,java.scripting,java.security.jgss,\
java.sql,java.xml,jdk.httpserver,jdk.unsupported
WORKDIR /build
COPY ./target/*.jar app.jar
RUN /usr/lib/jvm/java-11-openjdk/bin/jar -xf app.jar
RUN mkdir /app && cp -r META-INF /app && cp -r BOOT-INF/classes/* /app
 
# Second stage, add only our minimal "JRE" distr and our app
FROM alpine
COPY --from=0 /jvm /jvm
COPY --from=0 /build/BOOT-INF/lib /lib
COPY --from=0 /app .
ENTRYPOINT [ "/jvm/bin/java", "-cp", ".:/lib/*", "com.example.dockerExample.DockerExampleApplication" ]