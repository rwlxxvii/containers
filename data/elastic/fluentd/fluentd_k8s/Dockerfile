FROM gcr.io/google/ubuntu2004:latest

# Ensure there are enough file descriptors for running Fluentd.
RUN ulimit -n 65536

# Disable prompts from apt.
ENV DEBIAN_FRONTEND noninteractive

# Install fluentd
COPY install.sh /tmp/install.sh
RUN /tmp/install.sh

# Copy the Fluentd configuration file.
COPY td-agent.conf /etc/td-agent/td-agent.conf

# Run the Fluentd service.
ENTRYPOINT ["td-agent"]
