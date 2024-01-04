FROM ubuntu:20.04

# 将环境设置为非交互环境
ENV DEBIAN_FRONTEND=noninteractive

COPY ./src/ /src/

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
	&& apt update --no-install-recommends\
    && apt install -y openssh-server gcc-10 dwarfdump build-essential unzip \
    && mkdir /app \
    && sed -i 's/\#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/\#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config \
    && echo 'root:root' | chpasswd \
    && systemctl enable ssh \
    && service ssh start

WORKDIR /src

# 这里的文件名需要根据系统版本进行修改
COPY ./src/linux-image-unsigned-5.4.0-100-generic-dbgsym_5.4.0-100.113_amd64.ddeb linux-image-unsigned-5.4.0-100-generic-dbgsym_5.4.0-100.113_amd64.ddeb

RUN dpkg -i linux-image-unsigned-5.4.0-100-generic-dbgsym_5.4.0-100.113_amd64.ddeb \
    && chmod +x dwarf2json \
    # 下面这里的文件名需要根据系统版本进行修改
    && ./dwarf2json linux --elf /usr/lib/debug/boot/vmlinux-5.4.0-100-generic > linux-image-5.4.0-100-generic.json
	

CMD ["/bin/bash"]
