FROM ubuntu:22.04

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt -yq update && \
    apt -yqq install --no-install-recommends bc curl ca-certificates \
        build-essential pkg-config libssl-dev libunwind-dev llvm-dev liblmdb-dev locales clang cmake \
        git jq emacs vim

ENV HOME /home/sns
ENV WDIR ${HOME}
WORKDIR ${WDIR}
RUN locale-gen en_US.UTF-8 &&\
    echo "export LANG=en_US.UTF-8 LANGUAGE=en_US.en LC_ALL=en_US.UTF-8" >> /home/sns/.bashrc

ARG RUST_VERSION=1.67.0
ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    PATH=/opt/cargo/bin:$PATH
RUN curl --fail https://sh.rustup.rs -sSf \
        | sh -s -- -y --default-toolchain "${RUST_VERSION}-x86_64-unknown-linux-gnu" --no-modify-path && \
    rustup default "${RUST_VERSION}-x86_64-unknown-linux-gnu" && \
    rustup target add wasm32-unknown-unknown

RUN git clone https://github.com/dfinity/ic.git

ADD . ${WDIR}

RUN ./install.sh
ENV PATH=/home/sns/bin:$PATH

RUN mkdir -p /home/sns/.config/dfx
RUN echo '{ \n\
  "local": { \n\
    "bind": "0.0.0.0:8080", \n\
    "type": "ephemeral", \n\
    "replica": { \n\
      "subnet_type": "system", \n\
      "port": 8000 \n\
    } \n\
  } \n\
}' > /home/sns/.config/dfx/networks.json
