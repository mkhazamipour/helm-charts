# phpLDAPadmin Helm Chart

This Helm chart deploys phpLDAPadmin, a web-based LDAP administration tool.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- An existing secret containing the LDAP password

## Installing the Chart

To install the chart with the release name `phpldapadmin`:

```bash
helm install phpldapadmin . --namespace openldap --create-namespace
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `phpldapadmin/phpldapadmin` |
| `image.tag` | Image tag | `2.1.3` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `env.appKey` | Application key | `<INSERT_YOUR_APP_KEY>` |
| `env.appUrl` | Application URL | `http://phpldapadmin.openldap.svc.cluster.local:8080` |
| `env.ldapHost` | LDAP server host | `openldap.openldap` |
| `env.ldapBaseDn` | LDAP base DN | `dc=example,dc=org` |
| `env.ldapUsername` | LDAP admin username | `cn=admin,dc=example,dc=org` |
| `env.ldapLoginAttr` | LDAP login attribute | `cn` |
| `env.ldapPort` | LDAP server port | `389` |
| `env.ldapName` | LDAP server name | `OpenLDAP Server` |
| `secret.existingSecret` | Name of existing secret with LDAP password | `""` |
| `secret.ldapPasswordKey` | Key in secret containing LDAP password | `ldap-password` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |

## Using with Existing Secret

To use an existing secret for the LDAP password:

1. Create a secret with your LDAP password:
   ```bash
   kubectl create secret generic my-ldap-secret \
     --from-literal=ldap-password="YourSecretPassword" \
     --namespace openldap
   ```

2. Configure the chart to use the secret by setting values:
   ```bash
   helm install phpldapadmin . \
     --set secret.existingSecret=my-ldap-secret \
     --set secret.ldapPasswordKey=ldap-password \
     --namespace openldap
   ```

   Or use a values file:
   ```yaml
   secret:
     existingSecret: "my-ldap-secret"
     ldapPasswordKey: "ldap-password"
   ```

## Example Installation with Custom Values

```bash
# Install with custom values
helm install phpldapadmin . \
  --namespace openldap \
  --create-namespace \
  --set env.ldapHost=my-ldap-server.example.com \
  --set secret.existingSecret=my-ldap-secret \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=phpldapadmin.example.com
```

## Upgrading the Chart

To upgrade the chart:

```bash
helm upgrade phpldapadmin . --namespace openldap
```

## Uninstalling the Chart

To uninstall the chart:

```bash
helm uninstall phpldapadmin --namespace openldap
```
