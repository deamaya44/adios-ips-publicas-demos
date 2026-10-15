# Diagramas de arquitectura

Cada diagrama tiene su fuente `.drawio` (se abre con [draw.io](https://www.drawio.com/) o la extensión de VS Code) y sus exportaciones en PNG y SVG. Los logos son los oficiales de cada proyecto, embebidos en el archivo.

## 0 · Base compartida

Lo que usan dos o más demos lo instala `tools.sh up` una sola vez: el Gateway `entrada` (NGINX Gateway Fabric, Service `ClusterIP`) con sus tres listeners, cert-manager, origin-ca-issuer y, si hay `NB_PAT`, la base de NetBird. Esa base la crea Terraform con `enable_base=true`: grupos `k8s-routers` y `laptops`, sus setup keys, la red `cluster-demo` con su router y la zona privada. El `routing-peer` corre en el namespace `netbird`. `tools.sh laptop` une tu laptop en el perfil `adios-ips`. Cada demo solo agrega sus recursos, políticas y registros.

![Base](00-base.png)

## 1 · Demo 1: publicar sin abrir puertos

El usuario resuelve `demo.tu-dominio.com` en el DNS de Cloudflare y llega al borde por HTTPS 443. El borde manda la petición por el túnel `adios-ips-demo`, que el pod del `conector` mantiene abierto **desde adentro del cluster** (QUIC o HTTP/2, puerto 7844). El conector lee su `config.yaml` del ConfigMap `conector-config` y su identidad del Secret `tunel-token`, y entrega todo al Gateway `entrada` (NGINX Gateway Fabric, Service `ClusterIP`). El Gateway elige el Service `whoami` por hostname con el `HTTPRoute` `whoami`. Para publicar otra app basta otro `HTTPRoute`, sin otro túnel. El script `demo-1-tunel.sh up` crea el túnel, el CNAME y el token con `cloudflared` desde tu laptop. La opción A (`conector-rapido`) da una URL temporal sin cuenta.

![Demo 1](01-demo-1-tunel.png)

## 2 · Demo 2: conectar sin bastión

La laptop (perfil `adios-ips`, grupo `laptops`) y los dos `routing-peer` de la base (namespace `netbird`) se conectan hacia afuera al plano de control de NetBird, que reparte llaves, políticas y DNS. Los datos van por un túnel WireGuard entre ellos, directo o por relay. La demo 2 publica dos recursos `/32` y el routing peer hace masquerade solo hacia ellos: `postgres` por TCP 5432 y `kube-dns` por UDP 53. Postgres, en `demo-malla`, trae la tabla `clientes` y el rol `lector` de solo lectura. El registro `bd` vive en la zona privada de la base y no existe en el DNS público. Todo lo de NetBird lo crea Terraform (OpenTofu) desde `locals.tf`.

![Demo 2](02-demo-2-malla.png)

## 3 · Extra: HTTPS en el Gateway

El extra no depende de las demos: lo común viene de `tools.sh up`, todo lo suyo vive en el namespace `demo-extra` y el `ReferenceGrant` deja que el Gateway lea los certificados desde ahí.

**Caso A:** un túnel propio, `adios-ips-extra`, para `extra.tu-dominio.com`. cert-manager pide a Cloudflare Origin CA el certificado `publico-tls`, el listener `https-publico` lo sirve y el conector entra por el 443 validándolo con `originServerName`.

**Caso B:** el `ClusterIssuer` de Let's Encrypt valida con un TXT en Cloudflare (DNS-01), sin abrir puertos, y emite `interno-tls` para `pgadmin.interno.tu-dominio.com`, un nombre que solo existe en la malla. El extra trae su Postgres y usa el routing peer de la base; pgAdmin entra como `lector` con un `pgpass` que sale de `postgres-lector`. Terraform agrega el recurso `gateway` `/32`, la política TCP 443 y el registro `pgadmin`.

![Extra certificados](03-extra-certificados.png)

## 4 · Scripts

Cada fila es un subcomando y sus pasos, en orden, con la herramienta que usa cada uno: `kubectl`, `cloudflared`, `netbird`, `helm` o Terraform. Arriba están las funciones compartidas de `lib.sh`. `tools.sh up` va primero porque instala la base que usan las demos. Los pasos en amarillo son `terraform apply`: siempre los corre la función `demo` de `lib.sh`.

![Scripts](04-scripts.png)

## Regenerar las exportaciones

Después de editar un `.drawio`, con draw.io desktop:

```bash
DRAWIO=/Applications/draw.io.app/Contents/MacOS/draw.io   # en Linux: drawio
for f in docs/diagrams/*.drawio; do
  "$DRAWIO" -x -f png -s 2 -b 20 --theme light -o "${f%.drawio}.png" "$f"
  "$DRAWIO" -x -f svg -b 20 --theme light -o "${f%.drawio}.svg" "$f"
done
```
