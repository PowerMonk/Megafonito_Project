# Use the official Deno image based on Alpine Linux
FROM denoland/deno:alpine

# Create a user with permissions to run the app
# -S -> create a system user
# -G -> add the user to a group
RUN addgroup app && adduser -S -G app app

# Set the working directory inside the container to /app
WORKDIR /app

# Set DENO_DIR to a writable directory
ENV DENO_DIR=/app/.deno

# Ensure the directory exists and is owned by the app user
RUN mkdir -p ${DENO_DIR} && chown -R app:app ${DENO_DIR}

# Copy deno.json and deno.lock to the working directory (if they exist)
COPY --chown=app:app deno*.json ./

# Copy the rest of the files from the current directory to the working directory in the container
# Use --chown to ensure the files are owned by the app user
COPY --chown=app:app . .

# Cache dependencies to speed up subsequent builds
# Replace [filename].ts with your entry point file
RUN deno cache main.ts

# Expose port 8000 to allow external access to the application
EXPOSE 8000

# Set the user to run the app
USER app

# Command to run the application
# "deno task dev-server" should be defined in your deno.json file
CMD ["deno", "task", "server"]