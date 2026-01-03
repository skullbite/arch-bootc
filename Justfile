image_name := env("BUILD_IMAGE_NAME", "arch-cosmic")
image_tag := env("BUILD_IMAGE_TAG", "latest")
base_dir := env("BUILD_BASE_DIR", ".")
filesystem := env("BUILD_FILESYSTEM", "ext4")

alias build := build-containerfile
alias build-img := generate-bootable-image

build-containerfile $image_name=image_name:
    sudo podman build -t "${image_name}:latest" .

bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /sys/fs/selinux:/sys/fs/selinux \
        -v /etc/containers:/etc/containers:Z \
        -v /var/lib/containers:/var/lib/containers:Z \
        -v /dev:/dev \
        -e RUST_LOG=debug \
        -v "{{base_dir}}:/data" \
        --security-opt label=type:unconfined_t \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 20G "${base_dir}/bootable.img"
    fi
    just bootc install to-disk --composefs-backend --via-loopback /data/bootable.img --filesystem "${filesystem}" --wipe --bootloader systemd

run-vm:
    podman run \
        -it \
        --replace \
        --rm \
        --name qemu \
        -p 8006:8006 \
        --device=/dev/kvm \
        --device=/dev/net/tun \
        --cap-add NET_ADMIN \
        --cap-add NET_RAW \
        -v "${PWD:-.}/qemu:/storage:Z" \
        -v "${PWD:-.}/bootable.img:/boot.img:Z" \
        --stop-timeout 120 \
        docker.io/qemux/qemu