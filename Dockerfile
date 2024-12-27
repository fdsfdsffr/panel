FROM ghcr.io/lescai-teaching/rstudio-docker-amd64:latest

# Set environment variables
ENV PASSWORD 'rstudio'
ENV PATH ${PATH}:/opt/software/bin
ENV PORT 8787
ENV DISABLE_AUTH true
ENV DEBIAN_FRONTEND=noninteractive  # Prevents unnecessary prompts during apt installs

# Set working directory
WORKDIR /home/rstudio

# Switch to root user for installing software
USER root

# Install necessary packages and latest version of Node.js
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y sudo git ffmpeg wget mc imagemagick curl libfontconfig1 libx11-6 libxtst6 libpng16-16 libjpeg62-turbo && \
    curl -sL https://deb.nodesource.com/setup_current.x | bash - && \
    apt install -y nodejs && \
    npm i -g pm2 && \
    apt clean

# Add sudo privileges to the RStudio user
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Fix file permissions so rstudio can modify files (also for root)
RUN chmod -R 777 /home/rstudio && \
    chown -R rstudio:rstudio /home/rstudio

# Disable AppArmor or SELinux (depends on the environment)
# AppArmor or SELinux might cause restrictions that result in killed processes
RUN apt install -y apparmor-utils && \
    aa-disable /etc/apparmor.d/* && \
    setenforce 0 || true  # Only works if SELinux is present, will ignore errors

# Optimize Docker process to avoid killing on illegal operations
# Prevent kernel from killing processes when running out of memory or exceeding limits
RUN sysctl -w vm.overcommit_memory=1 && \
    sysctl -w vm.panic_on_oom=1 && \
    sysctl -w fs.file-max=1000000

# Ensure the right user permissions and avoid security violations
RUN chmod -R 777 /home/rstudio && \
    chown -R rstudio:rstudio /home/rstudio

# Set the correct permissions for RStudio startup
RUN mkdir -p /home/rstudio && \
    chmod -R 777 /home/rstudio && \
    chown -R rstudio:rstudio /home/rstudio

# Expose the necessary ports
EXPOSE 8787

# Set entrypoint or CMD as needed
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "false"]
