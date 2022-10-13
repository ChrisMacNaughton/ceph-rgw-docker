```
$ docker build .
Sending build context to Docker daemon   2.56kB
Step 1/5 : FROM ubuntu:jammy
 ---> 216c552ea5ba
Step 2/5 : RUN apt-get update &&     apt-get install -yq software-properties-common &&      echo 'Acquire::AllowInsecureRepositories "true"; APT::Get::AllowUnathenticated "true";' > /etc/apt/apt.conf.d/99testy-mctest-test
 ---> Using cache
 ---> f4d09550b2f2
Step 3/5 : RUN add-apt-repository https://2.chacra.ceph.com/r/ceph/main/19969ad12e66ea7293c29e4d0230218701dded9f/ubuntu/jammy/flavors/default -y &&     apt-get install -yq --allow-unauthenticated radosgw
 ---> Using cache
 ---> e7f349347330
Step 4/5 : RUN echo "[client]\n"     "rgw backend store = dbstore\n"     "rgw config store = dbstore\n"     "debug rgw = 50\n" > /etc/ceph/ceph.conf
 ---> Running in 6d04039132c5
Removing intermediate container 6d04039132c5
 ---> bca57dff1785
Step 5/5 : CMD [ "/usr/bin/radosgw", "--no-mon-config", "-f", "--cluster", "ceph" ]
 ---> Running in 7f7e8045f243
Removing intermediate container 7f7e8045f243
 ---> 063647983ff6
Successfully built 063647983ff6
$ docker run --rm -v `pwd`/rgw:/var/lib/ceph/radosgw --name rgw -p 7480:7480 063647983ff6
```

In another terminal:

```
$ docker exec -it rgw radosgw-admin user create --uid="icey" --display-name="icey"
2022-10-13T14:05:01.573+0000 7fe9d4e10a40  0 rgw dbstore: DB initialization full db_path("/var/lib/ceph/radosgw/dbstore-default_ns")
2022-10-13T14:05:01.573+0000 7fe9d4e10a40  0 rgw DBStore backend: Opened database(/var/lib/ceph/radosgw/dbstore-default_ns.db) successfully
2022-10-13T14:05:01.573+0000 7fe9d4e10a40  0 rgw DBStore backend: DB successfully initialized - name:/var/lib/ceph/radosgw/dbstore-default_ns
2022-10-13T14:05:01.573+0000 7fe9d3dd5640  2  DB GC started 
2022-10-13T14:05:01.577+0000 7fe9d4e10a40  0 In GetUser - No user with query(user_id), user_id(icey) found
2022-10-13T14:05:01.577+0000 7fe9d4e10a40  0 In GetUser - No user with query(access_key), user_id() found
2022-10-13T14:05:01.577+0000 7fe9d4e10a40  0 In GetUser - No user with query(user_id), user_id(icey) found
{
    "user_id": "icey",
    "display_name": "icey",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "icey",
            "access_key": "K1HAPAE29HZC52BJ3AX3",
            "secret_key": "ncpQW8yey2jY5I5UpI4FMwIBm7XrSWBq9ns1Q8bG"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}

$ docker exec -it rgw radosgw-admin user info --uid=icey
2022-10-13T14:05:41.022+0000 7efe766c1a40  0 rgw dbstore: DB initialization full db_path("/var/lib/ceph/radosgw/dbstore-default_ns")
2022-10-13T14:05:41.022+0000 7efe766c1a40  0 rgw DBStore backend: Opened database(/var/lib/ceph/radosgw/dbstore-default_ns.db) successfully
2022-10-13T14:05:41.022+0000 7efe766c1a40  0 rgw DBStore backend: DB successfully initialized - name:/var/lib/ceph/radosgw/dbstore-default_ns
2022-10-13T14:05:41.022+0000 7efe75686640  2  DB GC started 
{
    "user_id": "icey",
    "display_name": "icey",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "icey",
            "access_key": "K1HAPAE29HZC52BJ3AX3",
            "secret_key": "ncpQW8yey2jY5I5UpI4FMwIBm7XrSWBq9ns1Q8bG"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
$ # can also `docker exec -it rgw s3cmd ...`
$ s3cmd -c s3test.cfg mb s3://foo
Bucket 's3://foo/' created
$ s3cmd -c rgw/s3test.cfg put Dockerfile s3://foo
upload: 'Dockerfile' -> 's3://foo/Dockerfile'  [1 of 1]
 663 of 663   100% in    0s    62.58 KB/s  done

$ s3cmd -c rgw/s3test.cfg get s3://foo/Dockerfile -
download: 's3://foo/Dockerfile' -> '-'  [1 of 1]
 663 of 663   100% in    0s    15.33 KB/sFROM ubuntu:jammy
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
 663 of 663   100% in    0s    15.29 KB/s  donef", "--cluster", "ceph" ]
```