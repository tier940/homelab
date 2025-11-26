FROM --platform=$BUILDPLATFORM docker.io/debian:bookworm-20250407-slim

ARG TARGETOS TARGETARCH
ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1000
ARG KUBE_VERSION=v1.34.1
ARG HELM_VERSION=v3.7.1
ARG HELMFILE_VERSION=1.0.0

# Install dependencies
RUN apt-get update -y && \
  apt-get install -y fish curl tar && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -g ${GID} ${GROUPNAME} && \
  useradd -m -u ${UID} -g ${GID} -s /usr/bin/fish ${USERNAME}

# Install kubectl
USER ${USERNAME}
RUN mkdir -pv /home/${USERNAME}/bin/kubectl_${KUBE_VERSION} && \
  curl -L "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl" -o /home/${USERNAME}/bin/kubectl_${KUBE_VERSION}/kubectl && \
  chmod +x /home/${USERNAME}/bin/kubectl_${KUBE_VERSION}/kubectl && \
  ln -s /home/${USERNAME}/bin/kubectl_${KUBE_VERSION}/kubectl /home/${USERNAME}/bin/kubectl

# Install helm
RUN mkdir -pv /home/${USERNAME}/bin/helm_${HELM_VERSION} && \
  curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz -C /home/${USERNAME}/bin/helm_${HELM_VERSION} && \
  chmod +x /home/${USERNAME}/bin/helm_${HELM_VERSION}/linux-amd64/helm && \
  ln -s /home/${USERNAME}/bin/helm_${HELM_VERSION}/linux-amd64/helm /home/${USERNAME}/bin/helm

# Install helmfile
RUN mkdir -pv /home/${USERNAME}/bin/helmfile_v${HELMFILE_VERSION} && \
  curl -L "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz" | tar -xz -C /home/${USERNAME}/bin/helmfile_v${HELMFILE_VERSION} && \
  chmod +x /home/${USERNAME}/bin/helmfile_v${HELMFILE_VERSION}/helmfile && \
  ln -s /home/${USERNAME}/bin/helmfile_v${HELMFILE_VERSION}/helmfile /home/${USERNAME}/bin/helmfile

# Finalize
ENV PATH=$PATH:/home/${USERNAME}/bin
WORKDIR /home/${USERNAME}
ENTRYPOINT ["/usr/bin/fish"]
