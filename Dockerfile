# Use a minimal Ubuntu base image
FROM ubuntu:22.04

# Set environment variables
ENV USERNAME=cloudide

# # Install necessary packages
RUN apt-get update && apt-get install -y cron curl zip unzip

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update && \
    rm -rf awscliv2.zip aws

# Install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN apt-get update && \
    apt-get install -y python3 build-essential

# Verify AWS CLI is installed correctly by printing the version
RUN aws --version

# Create the user and home directory
RUN useradd -m -s /bin/bash -p '*' $USERNAME

# Create a directory for the user to work in
RUN mkdir -p /home/$USERNAME


# Set up the user permissions
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Create AWS credentials for root user
RUN mkdir -p /root/.aws && \
    echo "[default]" > /root/.aws/config && \
    echo "region = us-east-1" >> /root/.aws/config && \
    echo "[default]" > /root/.aws/credentials && \
    echo "aws_access_key_id = KEY" >> /root/.aws/credentials && \
    echo "aws_secret_access_key = SECREAT" >> /root/.aws/credentials


# Download template
RUN aws s3 sync s3://cloudide/nodejs/ /home/$USERNAME
# RUN "aws s3 ls"


# Switch back to root
# USER root

RUN mkdir /app && \
    chown root:root /app && \
    chmod 700 /app  # Only root can read, write, and execute



# Create a sync script
# RUN echo "#!/bin/bash\n" \
#     "aws s3 sync /home/$USERNAME s3://YOUR_BUCKET_NAME/ --delete" > /usr/local/bin/sync_to_s3.sh && \
#     chmod +x /usr/local/bin/sync_to_s3.sh


# RUN echo "#!/bin/bash\n" \
#     "echo 'This is a test command running every minute.'" > /usr/local/bin/sync_to_s3.sh && \
#     chmod +x /usr/local/bin/sync_to_s3.sh

# # # Setup cron job to run every minute
# RUN echo "* * * * * /usr/local/bin/sync_to_s3.sh >> /var/log/cron.log 2>&1" | crontab - && \
#     touch /var/log/cron.log

# # Start cron and shell
# CMD cron


# Runner
WORKDIR /app

COPY runner .

EXPOSE 8080

RUN npm install

CMD ["npm","run" "dev"]



# Set up limited access for the user
RUN chmod 700 /home/$USERNAME && \
chown $USERNAME:$USERNAME /home/$USERNAME

# USER $USERNAME

# # # Customize the bash prompt to display only the username
# RUN echo "export PS1='${USERNAME}$ '" >> /home/$USERNAME/.bashrc

# WORKDIR /home/$USERNAME
# # # Start bash shell with limited access
# CMD ["/bin/bash"]


