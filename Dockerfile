FROM ghcr.io/lescai-teaching/rstudio-docker-amd64:latest

# Set environment variables
ENV PATH ${PATH}:/opt/software/bin
ENV PORT 8787
ENV DISABLE_AUTH true

# Set working directory
WORKDIR /home/rstudio

# Switch to root user
USER root

# Install necessary packages and latest version of Node.js
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y sudo git ffmpeg wget mc imagemagick curl && \
    curl -sL https://deb.nodesource.com/setup_current.x | bash - && \
    apt install -y nodejs && \
    npm i -g pm2

# Add sudo privileges to the RStudio user
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up automatic login
RUN echo "auth-none=1" >> /etc/rstudio/rserver.conf && \
    echo "server-user=rstudio" >> /etc/rstudio/rserver.conf

# Fix file permissions so rstudio can modify files (also for root)
RUN chmod -R 777 /home/rstudio && \
    chown -R rstudio:rstudio /home/rstudio

# Expose the necessary ports
EXPOSE 8787

# Set entrypoint or CMD as needed
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "false"]
