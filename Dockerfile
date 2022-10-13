FROM ubuntu:jammy
RUN apt-get update && \
    apt-get install -yq software-properties-common s3cmd &&  \
    echo 'Acquire::AllowInsecureRepositories "true"; APT::Get::AllowUnathenticated "true";' > /etc/apt/apt.conf.d/99testy-mctest-test

RUN add-apt-repository https://2.chacra.ceph.com/r/ceph/main/19969ad12e66ea7293c29e4d0230218701dded9f/ubuntu/jammy/flavors/default -y && \
    apt-get install -yq --allow-unauthenticated radosgw

RUN echo "[client]\n" \
    "rgw backend store = dbstore\n" \
    "rgw config store = dbstore\n" \
    "debug rgw = 5\n" > /etc/ceph/ceph.conf
EXPOSE 7480
CMD [ "/usr/bin/radosgw", "--no-mon-config", "-f", "--cluster", "ceph" ]