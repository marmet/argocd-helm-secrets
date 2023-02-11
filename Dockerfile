ARG ARGOCD_VERSION="v2.6.1"
FROM argoproj/argocd:$ARGOCD_VERSION
ARG SOPS_VERSION="3.7.3"
ARG VALS_VERSION="0.21.0"
ARG HELM_SECRETS_VERSION="4.2.2"
ARG KUBECTL_VERSION="1.25.6"
# In case wrapper scripts are used, HELM_SECRETS_HELM_PATH needs to be the path of the real helm binary
ENV HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
    HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false

USER root
RUN apt-get update && \
    apt-get install -y \
      curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# helm secrets wrapper mode installation (optional)
# RUN printf '#!/usr/bin/env sh\nexec %s secrets "$@"' "${HELM_SECRETS_HELM_PATH}" >"/usr/local/sbin/helm" && chmod +x "/usr/local/sbin/helm"

# sops backend installation (optional)
RUN curl -fsSL https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux \
    -o /usr/local/bin/sops && chmod +x /usr/local/bin/sops

# vals backend installation (optional)
RUN curl -fsSL https://github.com/variantdev/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_amd64.tar.gz \
    | tar xzf - -C /usr/local/bin/ vals \
    && chmod +x /usr/local/bin/vals

USER argocd

RUN helm plugin install --version ${HELM_SECRETS_VERSION} https://github.com/jkroepke/helm-secrets
