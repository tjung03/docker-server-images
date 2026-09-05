# 실행 가이드

[프로젝트 소개](../README.md)

모든 Docker 명령은 저장소 루트를 기준으로 실행합니다. WEB 단독 실행은 루트 README에 있습니다.

## NFS 단독 실행

Linux Docker 호스트의 커널이 `nfsd`를 지원해야 합니다. 호스트에서 이미 NFS 서버가 실행 중이라면 커널 서버와 TCP `2049` 사용이 충돌할 수 있으므로 별도의 실습 호스트를 사용합니다.

아래 예시는 host 네트워크로 서버를 실행합니다. `NFS_CLIENT`에는 서버에 접근할 **실제 클라이언트 IPv4 주소**를 입력합니다.

```bash
read -r -p 'NFS 클라이언트 IPv4 주소: ' NFS_CLIENT
test -n "$NFS_CLIENT" || exit 1
docker build -t infra-nfs:1.0 ./nfs
docker volume create nfs-share
docker run -d --name mynfs --privileged --network host \
  -e NFS_ALLOWED_CLIENTS="$NFS_CLIENT" \
  -v nfs-share:/exports \
  infra-nfs:1.0
```

host 네트워크에서는 호스트의 TCP `2049`를 직접 사용합니다. 호스트 방화벽도 해당 클라이언트의 접근을 허용해야 합니다.

```bash
docker logs mynfs
docker exec mynfs exportfs -v
```

로그에서 export 생성과 서버 시작을 확인하고, `exportfs -v`에서 `/exports`, `/exports/share` 및 지정한 클라이언트 주소를 확인합니다.

### 클라이언트에서 공유 확인

NFS 클라이언트 도구가 설치된 별도의 Linux 시스템에서 실행합니다. Rocky Linux 계열은 `nfs-utils`, Debian·Ubuntu 계열은 `nfs-common` 패키지를 사용합니다.

```bash
read -r -p 'NFS 서버 IPv4 주소: ' NFS_SERVER
test -n "$NFS_SERVER" || exit 1
sudo mkdir -p /mnt/infra-share
sudo mount -t nfs -o vers=4,proto=tcp "$NFS_SERVER:/share" /mnt/infra-share
findmnt /mnt/infra-share
sudo sh -c 'printf "infra-nfs check\n" > /mnt/infra-share/logs/infra-check.txt'
cat /mnt/infra-share/logs/infra-check.txt
```

서버 호스트에서 같은 파일을 확인합니다.

```bash
docker exec mynfs cat /exports/share/logs/infra-check.txt
```

두 위치에서 `infra-nfs check`가 보이면 클라이언트 쓰기와 서버 읽기 경로가 연결된 것입니다. 확인 후 클라이언트에서 테스트 파일과 마운트를 정리합니다.

```bash
sudo rm /mnt/infra-share/logs/infra-check.txt
sudo umount /mnt/infra-share
```

서버 호스트에서 컨테이너를 종료합니다. `nfs-share` 볼륨은 이후 실행에서도 재사용합니다.

```bash
docker stop mynfs
docker rm mynfs
```

### 공유 경로와 환경변수

| 서버 컨테이너 경로 | 클라이언트 경로 | 용도 |
|---|---|---|
| `/exports` | `서버주소:/` | NFSv4 기준 경로, Docker 볼륨 연결점 |
| `/exports/share` | `서버주소:/share` | 파일 공유 디렉토리 |
| `/exports/share/logs` | 공유 마운트 아래 `logs/` | 로그 저장용 디렉토리 |

[entrypoint.sh](../nfs/entrypoint.sh)가 시작할 때 `/etc/exports.d/nfs.exports`를 생성합니다.

| 환경변수 | 기본값 | 역할 |
|---|---|---|
| `NFS_V4_ROOT` | `/exports` | NFSv4 기준 경로 |
| `NFS_EXPORT_NAME` | `share` | 기본 공유 디렉토리 이름 |
| `NFS_EXPORT_DIR` | `${NFS_V4_ROOT}/${NFS_EXPORT_NAME}` | 실제 export 대상 경로 |
| `NFS_LOG_DIR` | `${NFS_EXPORT_DIR}/logs` | 시작 시 생성할 로그 경로 |
| `NFS_ALLOWED_CLIENTS` | `*` | 접근 대상, 여러 값은 공백으로 구분 |
| `NFS_EXPORT_OPTIONS` | `rw,sync,no_subtree_check,no_root_squash,insecure` | 공유 디렉토리 export 옵션 |
| `NFS_V4_ROOT_OPTIONS` | `rw,fsid=0,crossmnt,no_subtree_check,no_root_squash,insecure` | 기준 경로 export 옵션 |
| `NFS_SERVER_THREADS` | `8` | 커널 NFS 서버 스레드 수 |
| `NFS_SHARE_MODE` | `0777` | 공유·로그 디렉토리 권한 |

기본 설정은 모든 클라이언트(`*`)의 접근과 root 권한 유지(`no_root_squash`), 공유 디렉토리 쓰기(`0777`)를 허용하는 실습 구성입니다. 위 실행 예시는 `NFS_ALLOWED_CLIENTS`로 접근 대상을 지정합니다.

공유 이름은 기본 경로 조합을 통해 실제 디렉토리에 반영됩니다. `NFS_EXPORT_DIR`를 직접 지정하면 클라이언트 경로도 기준 경로 아래의 실제 디렉토리 위치에 맞춰 사용해야 합니다.

## WEB 콘텐츠

[Dockerfile](../web/Dockerfile)은 `ADD src.tar /var/www/html`로 콘텐츠를 배치합니다. 아카이브에는 다음 세 파일이 있습니다.

| 파일 | 역할 |
|---|---|
| `index.html` | 홈 페이지 |
| `error.html` | 사용자 지정 404 페이지 |
| `.htaccess` | `ErrorDocument 404 /error.html` 설정 |

내용을 확인하려면 다음 명령을 사용합니다.

```bash
tar -tf web/src.tar
tar -xOf web/src.tar .htaccess
```

`web/index.html` 또는 `web/error.html`을 수정한 뒤에는 아카이브도 갱신하고 이미지를 다시 빌드합니다. 다음 명령은 기존 `.htaccess`를 보존하면서 두 HTML 파일을 반영합니다.

```bash
WEB_STAGE=$(mktemp -d)
tar -xf web/src.tar -C "$WEB_STAGE"
cp web/index.html web/error.html "$WEB_STAGE/"
tar -cf web/src.tar -C "$WEB_STAGE" index.html error.html .htaccess
rm -r "$WEB_STAGE"
docker build -t infra-web:1.0 ./web
```

Compose의 `web-html`에 기존 데이터가 있으면 그 데이터가 이미지의 콘텐츠보다 우선합니다. 이미지 재빌드 후에도 페이지가 같다면 마운트된 볼륨의 내용을 확인합니다. [Docker 볼륨 동작](https://docs.docker.com/engine/storage/volumes/)

## Compose 실행 구성

[Compose 파일](../compose/docker-compose.yml)은 아래 서비스의 이름·포트·볼륨·IP를 정의합니다. 이미지 빌드는 각 디렉토리에서 수행하고, Compose는 준비된 `infra-*:1.0` 이미지를 사용합니다.

| 서비스 | 호스트 → 컨테이너 포트 | 볼륨 → 컨테이너 경로 | IP 끝자리 |
|---|---|---|---|
| `mynfs` | `2049 → 2049` TCP | `nfs-share → /exports` | `.50` |
| `myweb` | `8080 → 80`, `8443 → 443` TCP | `web-html → /var/www/html`, `web-logs → /var/log/httpd` | `.20` |
| `mydns` | `5353 → 53` TCP·UDP | — | `.10` |
| `myftp` | `2121 → 21`, `21100–21110 → 21100–21110` TCP | `ftp-pub → /var/ftp/pub` | `.30` |
| `mymail` | `2525 → 25`, `8143 → 143`, `8081 → 80` TCP | `mail-home → /home` | `.40` |
| `test-client` | — | — | `.100` |

네트워크는 `infra-net`, 서브넷은 `172.30.0.0/24`, 게이트웨이는 `172.30.0.1`입니다. Compose 볼륨의 실제 Docker 이름에는 기본적으로 프로젝트 이름이 붙습니다.

WEB·NFS를 선택해 시작하려면 두 이미지를 빌드한 뒤 다음 명령을 실행합니다. 단독 실행 예시의 `myweb`·`mynfs` 컨테이너는 먼저 종료·제거하여 이름과 포트를 비워 둡니다. NFS의 Linux 커널·권한 조건도 동일하게 적용됩니다.

```bash
docker build -t infra-web:1.0 ./web
docker build -t infra-nfs:1.0 ./nfs
docker compose -f compose/docker-compose.yml config
docker compose -f compose/docker-compose.yml up -d mynfs myweb
docker compose -f compose/docker-compose.yml ps
docker compose -f compose/docker-compose.yml logs mynfs myweb
```

Compose의 NFS는 브리지 네트워크와 포트 게시를 사용하며, 위 단독 실행 예시는 host 네트워크를 사용합니다. Compose NFS의 허용 대상은 기본값 `*`입니다.

`myweb`의 `depends_on: mynfs`는 컨테이너 시작 순서를 지정합니다. 서비스 준비 완료를 기다리려면 상태 확인 조건이 필요합니다. WEB 로그는 `web-logs`, NFS 공유는 `nfs-share`에 각각 저장되므로 NFS로 로그를 모으려면 별도의 클라이언트 마운트를 구성해야 합니다. [Docker Compose 시작 순서](https://docs.docker.com/compose/how-tos/startup-order/)

전체 서비스를 실행하려면 DNS·FTP·MAIL 이미지도 `infra-dns:1.0`, `infra-ftp:1.0`, `infra-mail:1.0` 이름으로 준비해야 합니다. `test-client`는 이들을 포함한 다섯 서비스에 의존하고 DNS로 `172.30.0.10`을 사용합니다. 현재 `main`에서 직접 빌드할 수 있는 대상은 WEB·NFS입니다.

Compose 컨테이너와 네트워크 종료·제거:

```bash
docker compose -f compose/docker-compose.yml down
```

## 설치 패키지 확인

이미지를 빌드한 환경에서 패키지 버전을 확인합니다. NFS 이미지는 진입점을 바꿔 조회하므로 서버를 시작하지 않습니다.

```bash
docker run --rm --entrypoint rpm infra-web:1.0 -q httpd mod_ssl openssl
docker run --rm --entrypoint rpm infra-nfs:1.0 -q nfs-utils procps-ng iproute util-linux
```
