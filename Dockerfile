FROM registry.redhat.io/ansible-automation-platform/ee-29-rhel8:latest

RUN microdnf update -y --nodocs --setopt=install_weak_deps=0 --setopt=*.excludepkgs=ansible-core  \
  && microdnf clean all \
  && rm -rf /var/cache/{dnf,yum} \
  && rm -rf /var/lib/dnf/history.* \
  && rm -rf /var/log/*

RUN microdnf install git \
    && microdnf install python3-lxml \
    && microdnf install wget

WORKDIR /usr/local/bin
RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
RUN tar xvf oc.tar.gz

RUN mkdir -p /tmp/tests/ansible-tests
WORKDIR /tmp/tests/ansible-tests
COPY . .

# Make Ansible happy with arbitrary UID/GID in OpenShift.
RUN chmod g=u /etc/passwd /etc/group

RUN chgrp -R 0 /tmp && \
    chmod -R g=u /tmp

CMD ["/bin/bash"]

