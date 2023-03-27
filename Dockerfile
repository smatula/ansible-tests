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

# Add User maven-runner
RUN adduser \
   -m \
   --system \
   -u 1021 \
   rhscl-runner

RUN mkdir -p /tmp/tests/ansible-tests
#RUN git clone https://github.com/smatula/ansible-tests.git /tmp/tests/ansible-tests
WORKDIR /tmp/tests/ansible-tests
COPY . .

RUN chgrp -R rhscl-runner /tmp && \
    chmod -R g=u /tmp && \
    chgrp -R rhscl-runner /home/runner && \
    chmod -R g=u /home/runner

#Set User
USER rhscl-runner

CMD ["/bin/bash"]
#CMD ansible-playbook -e ext_test=dotnet_60 deploy-and-test.yml  
#CMD sleep 3600

