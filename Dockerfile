ARG PYTHON_VERSION=3.13.1-alpine3.21

FROM python:${PYTHON_VERSION}

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN set -ex && \
    apk update && \
    apk add openjdk21 && \
    apk add git wget net-tools && \
    apk add openssh-server && \
    apk add rust cargo && \
    mkdir -p /var/run/sshd && \
    adduser -h /home/jenkins -s /bin/bash -D jenkins && \
    mkdir -p /home/jenkins/.ssh

COPY requirements.txt /tmp/requirements.txt

RUN set -ex && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    rm -rf /root/.cache/

RUN set -ex && \
    ansible-galaxy collection install ansible.posix && \
    ansible-galaxy collection install community.windows && \
    ansible-galaxy collection install community.postgresql && \
    ansible-galaxy collection install ansible.utils && \
    ansible-galaxy collection install ansible.windows && \
    ansible-galaxy collection install community.crypto && \
    ansible-galaxy collection install containers.podman && \
    ansible-galaxy collection install community.general && \
    ansible-galaxy collection install fortinet.fortios && \
    ansible-galaxy collection install ibm.storage_virtualize

COPY id_rsa.pub /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.ssh/

EXPOSE 22

CMD ["/usr/bin/sshd", "-D"]
