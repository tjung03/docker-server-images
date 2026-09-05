# docker-server-images

**Rocky Linux 9 기반 Apache 웹 서버와 NFSv4 공유 저장소를 Docker 이미지로 구성한 팀 프로젝트입니다.** 웹 콘텐츠·TLS 설정을 이미지에 담고, NFS 공유 경로와 접근 대상을 실행 시 환경변수로 설정합니다.

현재 `main`의 구현은 **WEB·NFS**입니다. DNS·FTP·MAIL은 서비스 이름, 포트, 볼륨을 정한 Compose 구성과 작업 디렉토리가 준비되어 있습니다.

## 주요 구현과 기여

| 구현 | 동작 | 코드·작업 기록 |
|---|---|---|
| NFSv4 서버 — tjung03 | 시작 시 export 설정 생성, 커널 NFS 서버 구동, 종료 신호에 따른 export·서버 정리 | [entrypoint.sh](nfs/entrypoint.sh), [PR #10](https://github.com/tjung03/docker-server-images/pull/10) |
| 공유 저장소 — tjung03 | `/exports`에 볼륨을 연결하고 `/share`를 클라이언트에 공개, 하위 `logs` 디렉토리 준비 | [NFS Dockerfile](nfs/Dockerfile), [export 구성 설명](nfs/exports.d/nfs.exports) |
| Apache 웹 서버 — joohuijin | HTTP·HTTPS 제공, 자체 서명 인증서 생성, `.htaccess`로 사용자 지정 404 응답 | [WEB Dockerfile](web/Dockerfile), [TLS 설정](web/ssl.conf), [PR #9](https://github.com/tjung03/docker-server-images/pull/9) |
| Compose 구성 보완 — tjung03 | FTP Passive 데이터 포트의 TCP 지정과 네트워크 설명 추가 | [PR #7](https://github.com/tjung03/docker-server-images/pull/7) |

NFS 구현은 컨테이너 내부 경로와 클라이언트 경로를 구분합니다. `/exports`를 NFSv4의 기준 경로(`fsid=0`)로 잡아, 클라이언트가 `서버주소:/share`로 공유 디렉토리에 접근하도록 구성했습니다. 설정 생성부터 `nfsd` 마운트, 서버 시작, 종료 처리까지 한 [진입 스크립트](nfs/entrypoint.sh)에 모았습니다.

## 저장소 구조

```text
.
├── web/                      # Apache 이미지, TLS 설정, 웹 콘텐츠 아카이브
├── nfs/
│   ├── Dockerfile            # NFS 패키지와 공유 디렉토리 구성
│   ├── entrypoint.sh         # 환경변수 → export 생성 → NFS 시작·종료
│   ├── exports.d/            # 기본 export 설정과 경로 설명
│   └── default-share/logs/   # 공유 저장소의 초기 디렉토리
├── compose/docker-compose.yml
├── dns/ · ftp/ · mail/       # 서비스별 작업 디렉토리
├── scripts/setup-bashrc.sh   # 팀 실습용 셸 설정
└── docs/
    ├── usage.md             # NFS 실행·확인, Compose 구성, WEB 콘텐츠
    └── collaboration.md     # 팀 작업 규칙과 이미지 배포 절차
```

## WEB 빠른 실행

Docker가 설치된 환경에서 저장소 루트를 기준으로 실행합니다. 호스트의 `8080`, `8443` 포트를 사용합니다.

```bash
git clone https://github.com/tjung03/docker-server-images.git
cd docker-server-images
docker build -t infra-web:1.0 ./web
docker run -d --name myweb -p 8080:80 -p 8443:443 infra-web:1.0
```

```bash
curl -i http://localhost:8080/
curl -ki https://localhost:8443/
curl -i http://localhost:8080/missing-page
```

홈 페이지의 `Welcome to infra-web Server!`와, 없는 경로의 HTTP `404` 및 `My Custom 404 Error Page` 응답을 확인합니다. HTTPS의 `-k`는 이미지에서 생성한 자체 서명 인증서를 사용하기 위한 실습 옵션입니다.

웹 콘텐츠는 [src.tar](web/src.tar)의 `index.html`, `error.html`, `.htaccess`를 빌드 시 `/var/www/html`에 풀어 배치합니다. 콘텐츠를 수정할 때는 [아카이브 갱신 방법](docs/usage.md#web-콘텐츠)을 따릅니다.

종료·제거:

```bash
docker stop myweb
docker rm myweb
```

## NFS 실행과 확인

NFS는 Docker 호스트의 Linux 커널 `nfsd`를 사용합니다. **NFS 서버를 실행할 수 있는 Linux 호스트와 `--privileged` 권한**, 클라이언트에서 서버로 연결할 TCP `2049`가 필요합니다.

[실행 가이드](docs/usage.md#nfs-단독-실행)에는 이미지 빌드, 허용 클라이언트 지정, 외부 Linux 클라이언트의 `:/share` 마운트, 파일 쓰기·읽기 확인을 정리했습니다. [PR #10](https://github.com/tjung03/docker-server-images/pull/10)에는 작성 당시의 로컬 빌드·서버 시작·외부 마운트·파일 생성 및 삭제 동기화 확인 기록이 있습니다.

## 사용 기술과 실행 구성

| 항목 | 저장소 설정 |
|---|---|
| 이미지 기반 | WEB·NFS 모두 `rockylinux:9` |
| WEB | `httpd`, `mod_ssl`, 빌드 시 생성하는 RSA 2048비트·365일 자체 서명 인증서 |
| NFS | `nfs-utils`, Linux 커널 NFS 서버, NFSv4 활성화·v3 비활성화 |
| 시작 스크립트 | Bash, 환경변수로 export·스레드 수·공유 권한 설정 |
| 통합 실행 구성 | Docker Compose, `infra-net` 브리지, `172.30.0.0/24` |
| 테스트 클라이언트 정의 | `alpine:3.23` |

패키지는 Rocky Linux 9 저장소에서 빌드 시 설치됩니다. `infra-web:1.0`과 `infra-nfs:1.0`은 프로젝트의 이미지 태그입니다. 실제 패키지 버전 확인 명령은 [실행 가이드](docs/usage.md#설치-패키지-확인)에 있습니다.

Compose에서 WEB은 `web-html`·`web-logs`, NFS는 `nfs-share`라는 별도 볼륨을 사용합니다. WEB의 `depends_on: mynfs`는 시작 순서를 지정하며, 로그 공유에는 NFS 클라이언트 마운트 구성이 추가로 필요합니다. [Compose 실행 구성](docs/usage.md#compose-실행-구성)에서 서비스별 포트와 저장 경로를 볼 수 있습니다.

팀의 브랜치·커밋·이미지 이름 규칙은 [협업 가이드](docs/collaboration.md)에 정리했습니다.
