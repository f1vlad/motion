# Use the official Ubuntu base image
FROM ubuntu:latest

# Install OpenSSH server and other necessary packages
RUN apt-get update && apt-get install -y openssh-server rsyslog && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for SSH run files
RUN mkdir /var/run/sshd

# Set up a non-root user (recommended for security)
# IMPORTANT: Replace 'your_strong_password' with an actual strong password
RUN useradd -m -s /bin/bash surveillanceuser && \
    echo "surveillanceuser:surveillanceuser" | chpasswd

# Optionally, if you want root SSH access (less secure, but sometimes useful for initial setup)
# RUN echo "root:your_strong_root_password" | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Disable password authentication for root if enabling another user
# And disable PAM (Pluggable Authentication Modules) for simpler container setup
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Create a directory for surveillance footage inside the container
RUN mkdir -p /var/lib/surveillance_footage
RUN chown -R surveillanceuser:surveillanceuser /var/lib/surveillance_footage

# Expose the SSH port
EXPOSE 22

# Command to run when the container starts
# Use -D to run sshd in the foreground so Docker can manage it
CMD ["/usr/sbin/sshd", "-D"]