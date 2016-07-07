docker run \
    --volume=/:/rootfs:ro \
    --volume=/sys:/sys:ro \
    --volume=/dev:/dev \
    --volume=/var/lib/docker/:/var/lib/docker:rw \
    --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
    --volume=/var/run:/var/run:rw \
    --net=host \
    --privileged=true \
    --pid=host \
    -d \
    gcr.io/google_containers/hyperkube-amd64:v1.2.4 \
    /hyperkube kubelet \
        --allow-privileged=true \
        --api-servers=http://MASTERIP:8080 \
        --v=2 \
        --address=0.0.0.0 \
        --enable-server \
        --hostname-override=LOCALIP \
        --containerized
