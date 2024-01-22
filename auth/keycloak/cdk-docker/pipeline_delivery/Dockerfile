FROM quay.io/keycloak/keycloak:22.0.5 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak

COPY /providers /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:22.0.5
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=builder /opt/keycloak/providers/ /opt/keycloak/providers/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]