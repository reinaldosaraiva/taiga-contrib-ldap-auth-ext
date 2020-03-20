#TODO: How to give ability to another version and variant?
FROM monogramm/docker-taiga-back-base:4.2-alpine
LABEL maintainer="Monogramm maintainers <opensource at monogramm dot io>"

# Taiga additional properties
ENV TAIGA_ENABLE_LDAP=False \
    TAIGA_LDAP_USE_TLS=True \
    TAIGA_LDAP_SERVER= \
    TAIGA_LDAP_PORT=389 \
    TAIGA_LDAP_BIND_DN= \
    TAIGA_LDAP_BIND_PASSWORD= \
    TAIGA_LDAP_BASE_DN= \
    TAIGA_LDAP_USERNAME_ATTRIBUTE=uid \
    TAIGA_LDAP_EMAIL_ATTRIBUTE=mail \
    TAIGA_LDAP_FULL_NAME_ATTRIBUTE=cn \
    TAIGA_LDAP_SAVE_LOGIN_PASSWORD=True \
    TAIGA_LDAP_FALLBACK=normal

# Erase original entrypoint and conf with custom one
COPY entrypoint.sh ./
COPY local.py /taiga/
# Fix entrypoint permissions
# Install LDAP extension
RUN set -ex; \
    chmod 755 /entrypoint.sh; \
    LC_ALL=C pip install --no-cache-dir taiga-contrib-ldap-auth-ext; \
    rm -r /usr/local/lib/python3.6/site-packages/taiga_contrib_ldap_auth_ext

COPY . /usr/local/lib/python3.6/site-packages/taiga_contrib_ldap_auth_ext
# Backend healthcheck
HEALTHCHECK CMD curl --fail http://127.0.0.1:8001/api/v1/ || exit 1