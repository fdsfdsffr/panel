FROM ghcr.io/lescai-teaching/rstudio-docker-amd64:latest

# Set environment variables
ENV PASSWORD 'rstudio'
ENV PATH ${PATH}:/opt/software/bin
ENV PORT 8787         # Default RStudio Server port
ENV DISABLE_AUTH true # Disable authentication for RStudio

# Set working directory
WORKDIR /home/rstudio

# Switch to root user
USER root

# Install necessary packages and the latest version of Node.js
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y sudo git ffmpeg wget mc imagemagick curl && \
    curl -sL https://deb.nodesource.com/setup_current.x | bash - && \
    apt install -y nodejs && \
    npm i -g pm2

# Add sudo privileges to the RStudio user
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure root to use /home/rstudio as its home directory
RUN usermod --home /home/rstudio root && \
    echo "cd /home/rstudio" >> /root/.bashrc

# Ensure proper permissions for /home/rstudio
RUN chown -R rstudio:rstudio /home/rstudio && \
    chmod -R 755 /home/rstudio

# Modify bash profile to start terminal as root automatically
RUN echo "sudo su -" >> /home/rstudio/.bashrc && \
    echo "export HOME=/home/rstudio" >> /home/rstudio/.bashrc && \
    chown rstudio:rstudio /home/rstudio/.bashrc

# Expose the necessary ports
EXPOSE 8787

# Set the entrypoint or CMD as needed
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "false"]
