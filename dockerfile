# ------------ Building Stage ----------------

FROM python:3.9 AS builder

#determining the working dir
WORKDIR /app


#Copying the dependencise, files that should be installed
COPY requirements.txt /app/
COPY . .

RUN apt-get update && apt-get install -y redis-server curl

#Installing the requirements & cleaning cache
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt 

# ------------ Production Stage ----------------

FROM python:3.9-slim AS production
WORKDIR /app

#RUN apt-get update && apt-get install -y redis-server && \
 #   apt-get clean && rm -rf /var/lib/apt/lists/*


#copy the shell script, dependencies, and code from builder
COPY --from=builder /install /usr/local
COPY --from=builder /usr/bin/redis-server /usr/bin/redis-server
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /app/ .

RUN chmod +x start.sh

#Expose app port
EXPOSE 8000

# Set environmet variables
ENV ENVIRONMENT=DEV \
    HOST=localhost \ 
    PORT=8000 \ 
    REDIS_HOST=localhost \
    REDIS_PORT=6379 \
    REDIS_DB=0

#naking a non-root user and switch to it
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
ENTRYPOINT [ "./start.sh" ]
CMD ["python3", "hello.py"]
