# docker-server-images

`docker-server-images`는 DNS, WEB, FTP, MAIL, NFS 서버 중 3개 서버 이미지를 Docker 이미지로 제작하고, Docker Hub에 업로드하여 사용법과 함께 공유하는 팀 프로젝트입니다.

이 저장소는 각 서버 이미지를 같은 기준으로 제작하기 위한 협업 공간입니다. `main` 브랜치에는 공통 구조와 합의된 결과물을 유지하고, 개인 작업은 각자 브랜치에서 진행한 뒤 Pull Request를 통해 반영합니다.

## 1. 프로젝트 개요

이 프로젝트의 목표는 서버별 Docker 이미지를 직접 제작하고, 각 이미지를 단독 실행 및 필요한 경우 통합 실행 환경에서 검증하는 것입니다.

구성 대상은 다음과 같습니다.

| Server | Image Name        | Container Name | Role |
| ------ | ----------------- | -------------- | ---- |
| DNS    | `infra-dns:1.0`   | `mydns`        | DNS 서버 |
| WEB    | `infra-web:1.0`   | `myweb`        | Apache 기반 HTTP/HTTPS 웹 서버 |
| FTP    | `infra-ftp:1.0`   | `myftp`        | Real FTP 및 Anonymous FTP 서버 |
| MAIL   | `infra-mail:1.0`  | `mymail`       | Web Mail 및 메일 보안 기능 제공 |
| NFS    | `infra-nfs:1.0`   | `mynfs`        | NFSv4 스토리지 공유 서버 |

각 서버 이미지는 Docker Hub에 업로드하고, Docker Hub README에는 이미지 사용법을 간단히 작성합니다.

## 2. 저장소 구조

```text
docker-server-images
├─ README.md
├─ .gitignore
├─ dns
├─ web
├─ ftp
├─ mail
├─ nfs
├─ compose
│  └─ docker-compose.yml
└─ scripts
   └─ setup-bashrc.sh
```

각 서버 작업은 지정된 디렉토리 안에서 진행합니다.

```text
dns   → DNS 서버 이미지 작업
web   → WEB 서버 이미지 작업
ftp   → FTP 서버 이미지 작업
mail  → MAIL 서버 이미지 작업
nfs   → NFS 서버 이미지 작업
```

README 파일은 제출 문서가 아닙니다. 제출 문서는 Notion에서 별도로 작성합니다.

## 3. 공통 이름 기준

이미지 이름, 컨테이너 이름, 네트워크 이름, volume 이름은 아래 기준을 사용합니다.

### Image

```text
infra-dns:1.0
infra-web:1.0
infra-ftp:1.0
infra-mail:1.0
infra-nfs:1.0
```

### Container

```text
mydns
myweb
myftp
mymail
mynfs
```

### Network

```text
infra-net
```

### Volume

```text
web-html
web-logs
ftp-pub
mail-home
nfs-share
```

### Integrated Network

```text
subnet  : 172.30.0.0/24
gateway : 172.30.0.1
```

### Integrated IP

```text
mydns       : 172.30.0.10
myweb       : 172.30.0.20
myftp       : 172.30.0.30
mymail      : 172.30.0.40
mynfs       : 172.30.0.50
test-client : 172.30.0.100
```

위 IP는 Docker 이미지 내부에 하드코딩하는 값이 아니라, `compose/docker-compose.yml`로 통합 검증 환경을 실행할 때 Docker Compose가 컨테이너에 부여하는 실행환경 기준값입니다.

DNS zone 파일의 A/MX 레코드는 통합 검증 환경에서 위 IP 기준과 일치해야 합니다.

## 4. 브랜치 작업 방식

`main` 브랜치는 공통 기준과 합의된 결과물을 유지하는 브랜치입니다.

개인 작업은 본인 브랜치에서 진행합니다. 브랜치 이름은 자유롭게 사용할 수 있으나, 개인 작업 브랜치는 본인 이니셜 사용을 권장합니다.

```bash
git switch -c <본인이니셜>
git push -u origin <본인이니셜>
```

예시:

```bash
git switch -c jth
git push -u origin jth
```

임시 작업 브랜치가 필요한 경우 아래처럼 구분할 수 있습니다.

```text
jth-temp
```

작업 완료 후에는 본인 브랜치에서 `main` 브랜치로 Pull Request를 생성합니다.

## 5. Git 작업 흐름

이 프로젝트는 `main` 브랜치에 직접 작업하지 않고, 개인 브랜치에서 작업한 뒤 Pull Request로 `main`에 반영한다.

### 5-1. Git 사용자 정보 설정

Git 사용자 정보는 VM에서 최초 1회 설정한다.

```bash
git config --global user.name "GitHub Name"
git config --global user.email "GitHub Email"
```

설정 확인:

```bash
git config --global --list | grep user
```

이 설정은 특정 브랜치에만 적용되는 것이 아니라, 해당 VM 사용자 계정의 Git commit 작성자 정보로 사용된다.

### 5-2. 처음 작업을 시작할 때

저장소를 clone한다.

```bash
git clone https://github.com/tjung03/docker-server-images.git
cd docker-server-images
```

`main` 브랜치가 최신 상태인지 확인한다.

```bash
git switch main
git pull origin main
```

개인 브랜치를 생성하고 이동한다.

```bash
git switch -c <본인이니셜>
```

예시:

```bash
git switch -c jth
```

처음 만든 개인 브랜치는 원격 저장소에 한 번 등록한다.

```bash
git push -u origin jth
```

`-u` 옵션은 로컬 브랜치와 원격 브랜치를 연결하는 옵션이다. 처음 한 번만 사용하면 이후에는 해당 브랜치에서 `git push`, `git pull`만 사용할 수 있다.

### 5-3. 브랜치 이동 및 확인

기존 브랜치로 이동할 때는 `-c` 옵션을 사용하지 않는다.

```bash
git switch jth
```

현재 로컬 브랜치 목록을 확인한다.

```bash
git branch
```

현재 위치한 브랜치는 `*`로 표시된다.

```text
* jth
  main
```

원격 브랜치 목록을 확인한다.

```bash
git branch -r
```

로컬 브랜치와 원격 브랜치를 모두 확인한다.

```bash
git branch -a
```

### 5-4. 작업 후 commit / push

현재 변경 상태를 확인한다.

```bash
git status
```

변경 파일을 commit 대상에 추가한다.

```bash
git add .
```

커밋을 생성한다.

```bash
git commit -m "feat(web): add apache Dockerfile" -m "Update HTTP/HTTPS web server image files"
```

첫 번째 `-m` 옵션은 커밋 제목, 두 번째 `-m` 옵션은 커밋 본문으로 사용한다.

개인 브랜치에 push한다.

```bash
git push
```

### 5-5. main이 갱신되었을 때 내 브랜치에 반영하는 방법

다른 팀원의 작업이 `main`에 merge되면, 내 개인 브랜치에도 최신 `main` 내용을 반영해야 한다.

먼저 현재 작업 상태를 확인한다.

```bash
git status
```

작업 중인 내용이 있다면 먼저 commit한다.

```bash
git add .
git commit -m "feat(web): add apache Dockerfile"
```

`main` 브랜치로 이동한 뒤 최신 내용을 가져온다.

```bash
git switch main
git pull origin main
```

다시 내 브랜치로 이동한다.

```bash
git switch jth
```

최신 `main` 내용을 내 브랜치에 반영한다.

```bash
git merge main
```

문제가 없으면 내 브랜치를 원격 저장소에 push한다.

```bash
git push
```

이 프로젝트에선 가능하면 아래 흐름을 사용한다.

```text
main으로 이동
→ git pull origin main
→ 내 브랜치로 이동
→ git merge main
→ 작업 계속
```

### 5-6. 주요 Git 명령어 의미

| 명령어 | 의미 |
|---|---|
| `git clone` | 원격 저장소를 로컬로 복사 |
| `git switch <branch>` | 기존 브랜치로 이동 |
| `git switch -c <branch>` | 새 브랜치를 만들고 이동 |
| `git status` | 현재 변경 상태 확인 |
| `git add` | commit할 파일을 staging area에 추가 |
| `git commit` | 현재 변경 내용을 하나의 기록으로 저장 |
| `git push` | 로컬 commit을 원격 저장소로 업로드 |
| `git fetch` | 원격 저장소의 최신 정보만 가져옴 |
| `git pull` | 원격 저장소의 최신 내용을 가져와 현재 브랜치에 반영 |
| `git merge` | 다른 브랜치의 변경 내용을 현재 브랜치에 합침 |
| `git branch` | 로컬 브랜치 목록 확인 |
| `git branch -r` | 원격 브랜치 목록 확인 |
| `git branch -a` | 로컬/원격 브랜치 전체 확인 |
| `git log` | commit 기록 확인 |

### 5-7. fetch, pull, merge 차이

`fetch`는 원격 저장소의 변경 정보를 가져오기만 한다. 현재 작업 파일에는 바로 반영하지 않는다.

```bash
git fetch origin
```

`pull`은 원격 저장소의 변경 내용을 가져오고 현재 브랜치에 반영한다.

```bash
git pull origin main
```

`merge`는 다른 브랜치의 변경 내용을 현재 브랜치에 합친다.

```bash
git merge main
```

일반 작업에서는 `main`으로 이동한 뒤 `git pull origin main`을 사용하고, 개인 브랜치에서 `git merge main`을 사용하는 흐름으로 통일한다.

```text
원격 main → 로컬 main
로컬 main → 로컬 개인 브랜치
```

### 5-8. commit 로그 확인

기본 로그 확인:

```bash
git log
```

간단한 로그 확인:

```bash
git log --oneline
```

브랜치 흐름을 함께 확인:

```bash
git log --oneline --graph --decorate --all
```

필요하면 아래 alias를 등록해서 짧게 사용할 수 있다.

```bash
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.st "status -sb"
```

등록 후 사용:

```bash
git lg
git st
```

### 5-9. Pull Request 흐름

개인 브랜치에서 작업을 완료하면 먼저 commit 후 push한다.

```bash
git status
git add .
git commit -m "feat(web): add apache web server image"
git push
```

`git push`는 개인 브랜치의 commit을 GitHub에 올리는 명령이다.  
`git push`만으로 `main`에 자동 반영되지는 않는다.

GitHub 저장소 페이지에서 Pull Request를 생성한다.

```text
base: main
compare: <개인 브랜치>
```

예시:

```text
base: main
compare: jth
```

Pull Request 제목 예시:

```text
[WEB] Apache HTTP/HTTPS 서버 이미지 구현
```

Pull Request 본문에는 아래 내용을 작성한다.

```text
- 작업한 내용
- 실행한 검증 명령
- 확인한 결과
- 문제 또는 미확인 사항
```

Pull Request가 확인된 뒤 `Merge pull request`를 누르면 개인 브랜치의 변경 내용이 `main`에 반영된다.

기본 흐름은 다음과 같다.

```text
개인 브랜치에서 작업
→ commit
→ push
→ GitHub 웹사이트에서 Pull Request 생성
→ 변경 내용 확인
→ Merge pull request
→ main에 반영
```

## 6. Commit Convention

커밋 메시지는 아래 형식을 권장합니다.

```text
<type>(<scope>): <message>
```

### type

```text
feat  : 기능 또는 파일 추가
fix   : 오류 수정
docs  : README 등 문서 수정
test  : 테스트 또는 검증 절차 추가
chore : 구조 정리, 설정 변경, 불필요 파일 정리
etc   : 위 항목으로 분류하기 애매한 기타 변경
```

### scope

```text
web
ftp
dns
mail
nfs
compose
readme
```

### Example

```text
feat(web): add apache httpd Dockerfile
feat(ftp): add real and anonymous ftp config
feat(dns): add example.com zone file
feat(mail): add webmail config
feat(nfs): add nfs v4 server config
fix(ftp): update passive port range
docs(readme): update server requirements
test(dns): add nslookup check command
chore(compose): update service names
etc: update repository settings
```

## 7. Issue / Pull Request 사용 방식

Issue는 작업 카드 용도로 사용합니다.

초기 Issue 예시는 다음과 같습니다.

```text
[DNS] DNS 서버 이미지 구현
[WEB] Apache HTTP/HTTPS 서버 이미지 구현
[FTP] Real FTP 및 Anonymous FTP 서버 이미지 구현
[MAIL] Web Mail 및 보안 기능 포함 메일 서버 이미지 구현
[NFS] NFSv4 서버 이미지 구현
[COMPOSE] 서버 이미지 통합 실행 및 검증
[DOCKERHUB] 이미지 업로드 및 사용법 작성
```

Pull Request 제목은 아래 형식을 권장합니다.

```text
[DNS] DNS 서버 이미지 구현
[WEB] Apache HTTP/HTTPS 서버 이미지 구현
[FTP] Real FTP 및 Anonymous FTP 서버 이미지 구현
[MAIL] Web Mail 및 보안 기능 포함 메일 서버 이미지 구현
[NFS] NFSv4 서버 이미지 구현
[COMPOSE] 서버 이미지 통합 실행 및 검증
[DOCKERHUB] 이미지 업로드 및 사용법 작성
```

Pull Request에는 가능한 다음 내용을 포함합니다.

```text
- 작업한 내용
- 실행 또는 검증한 명령
- 확인한 결과
- 추가로 확인이 필요한 부분
```

## 8. 작업 기준

작업 기준은 다음과 같습니다.

```text
- 서버별 작업은 지정된 디렉토리 안에서 진행합니다.
- 이미지 이름, 컨테이너 이름, volume 이름, network 이름은 README 기준을 따릅니다.
- Docker Hub에 업로드하는 이미지는 특정 통합 IP에 의존하지 않도록 제작합니다.
- 통합 검증이 필요한 경우 compose/docker-compose.yml의 서비스 이름과 이미지 이름을 기준으로 실행합니다.
- entrypoint.sh에는 필요한 경우 간단한 주석을 작성합니다.
- 설정 파일은 동작에 필요한 값을 중심으로 작성합니다.
```

서버별 세부 구현 방식은 각 담당자가 진행하되, 최종적으로 단독 실행 및 필요한 경우 통합 실행이 가능하도록 이미지 이름, 포트, volume, network 기준은 맞추는 것을 권장합니다.

## 9. 서버별 기준

### DNS

```text
작업 위치        : dns/
이미지 이름      : infra-dns:1.0
컨테이너 이름    : mydns
서비스 포트      : 53/udp, 53/tcp
테스트 호스트 포트: 5353:53
통합 IP          : 172.30.0.10
```

기본 레코드 기준:

```text
dns.example.com   → 172.30.0.10
www.example.com   → 172.30.0.20
ftp.example.com   → 172.30.0.30
mail.example.com  → 172.30.0.40
nfs.example.com   → 172.30.0.50
example.com MX    → mail.example.com
```

DNS 서버의 zone 파일에는 통합 검증용 A/MX 레코드가 포함된다. 이 레코드는 `compose/docker-compose.yml`에서 부여하는 고정 IP와 일치해야 한다.

단, 해당 IP는 Dockerfile에 하드코딩하지 않는다. Dockerfile은 BIND 설치, 설정 파일 복사, 포트 노출, 실행 명령 정의를 담당하고, 실제 컨테이너 IP는 Compose 실행환경에서 부여한다.

### WEB

```text
작업 위치        : web/
이미지 이름      : infra-web:1.0
컨테이너 이름    : myweb
서비스 포트      : 80/tcp, 443/tcp
테스트 호스트 포트: 8080:80, 8443:443
웹 루트          : /var/www/html
로그 경로        : /var/log/httpd
volume           : web-html:/var/www/html
통합 IP          : 172.30.0.20
```

WEB 서버는 Apache HTTP Server 기반으로 구성합니다.

구현 기준은 다음과 같습니다.

```text
- HTTP 서비스 제공
- HTTPS 서비스 제공
- .htaccess 사용 가능
- 로그 공간은 NFS 서버 자원을 마운트하여 사용
```

`.htaccess` 사용을 위해 Apache 설정에서 해당 웹 루트에 `AllowOverride All`이 적용되어야 합니다.

WEB 서버의 로그 저장 위치는 `/var/log/httpd`를 기준으로 하며, 통합 환경에서는 이 경로를 NFS 서버에서 제공하는 공유 자원과 연결하여 사용합니다. NFS 마운트는 이미지 내부에 고정하지 않고 실행 환경에서 volume 또는 mount 옵션으로 연결합니다.

### FTP

```text
작업 위치        : ftp/
이미지 이름      : infra-ftp:1.0
컨테이너 이름    : myftp
제어 포트        : 21/tcp
passive port     : 21100-21110/tcp
테스트 호스트 포트: 2121:21
volume           : ftp-pub:/var/ftp/pub
접속 방식        : real user, anonymous
통합 IP          : 172.30.0.30
```

FTP 서버는 Real FTP와 Anonymous FTP를 모두 사용할 수 있도록 구성합니다.

구현 기준은 다음과 같습니다.

```text
- Real FTP 접속 가능
- Anonymous FTP 접속 가능
- passive mode 포트 범위 지정
- FTP 공개 디렉토리 volume 분리
```

#### FTP passive mode 기준

FTP의 `PASV_ADDRESS`는 passive mode에서 FTP 서버가 클라이언트에게 알려주는 접속 주소입니다.

통합 검증에서는 `test-client` 컨테이너가 같은 `infra-net` 네트워크 안에서 FTP 서버에 접속하므로 `PASV_ADDRESS`는 `172.30.0.30`으로 설정합니다.

호스트 PC에서 포트 매핑을 통해 FTP 단독 테스트를 수행하는 경우에는 실행 환경에 따라 `PASV_ADDRESS`를 호스트에서 접근 가능한 IP 또는 호스트명으로 별도 지정해야 합니다. 따라서 `172.30.0.30`은 Docker Hub 이미지 자체의 고정값이 아니라 Compose 통합 검증용 실행환경 값입니다.

### MAIL

```text
작업 위치        : mail/
이미지 이름      : infra-mail:1.0
컨테이너 이름    : mymail
서비스 포트      : 25/tcp, 143/tcp, 80/tcp
테스트 호스트 포트: 2525:25, 8143:143, 8081:80
volume           : mail-home:/home
기본 도메인       : example.com
기본 수신 사용자  : user01@example.com, user02@example.com
통합 IP          : 172.30.0.40
```

MAIL 서버는 메일 송수신 기능과 Web Mail 접근 기능을 포함하여 구성합니다.

구현 기준은 다음과 같습니다.

```text
- SMTP 기반 메일 수신
- IMAP 기반 메일 조회
- Web Mail 접속 가능
- Anti-Spam 기능 포함
- Anti-Virus 기능 포함
```

메일 관련 세부 프로그램은 구현 방식에 따라 조정할 수 있으나, 최종 이미지는 기본 메일 수신, Web Mail 접속, 스팸 및 바이러스 검사 기능을 설명할 수 있어야 합니다.

### NFS

```text
작업 위치        : nfs/
이미지 이름      : infra-nfs:1.0
컨테이너 이름    : mynfs
서비스 포트      : 2049/tcp
테스트 호스트 포트: 2049:2049
공유 경로        : /exports
volume           : nfs-share:/exports
통합 IP          : 172.30.0.50
```

NFS 서버는 NFSv4 기반으로 자신의 스토리지를 공유할 수 있도록 구성합니다.

구현 기준은 다음과 같습니다.

```text
- NFSv4 서비스 제공
- /exports 경로 공유
- 외부 컨테이너 또는 호스트에서 공유 자원 마운트 가능
- WEB 서버 로그 저장 공간으로 사용할 수 있는 공유 자원 제공
```

NFS 서버 컨테이너는 실행 환경에 따라 추가 권한이 필요할 수 있습니다. 필요한 경우 `--privileged` 또는 capability 옵션을 사용하여 테스트합니다.

## 10. Build Usage

각 서버 이미지는 프로젝트 루트에서 빌드합니다.

```bash
docker build -t infra-dns:1.0 ./dns
docker build -t infra-web:1.0 ./web
docker build -t infra-ftp:1.0 ./ftp
docker build -t infra-mail:1.0 ./mail
docker build -t infra-nfs:1.0 ./nfs
```

이미지 확인:

```bash
docker images | grep infra-
```

정상 기준:

```text
infra-dns
infra-web
infra-ftp
infra-mail
infra-nfs
```

실제 빌드와 검증은 구현한 서버 이미지를 기준으로 진행합니다.

## 11. Compose Integrated Run

`compose/docker-compose.yml`은 필요한 경우 서버 이미지를 같은 Docker 네트워크에서 실행하기 위한 통합 실행 기준 파일입니다.

Compose 파일은 각 서버 이미지 제작을 대체하지 않습니다. 각 서버 디렉토리의 Dockerfile로 이미지를 만든 뒤, Compose를 사용하여 구현한 서버들을 하나의 Docker 네트워크에서 실행합니다.

통합 실행은 필요한 서버 이미지가 준비된 뒤 진행합니다.

```bash
cd compose
docker compose up -d
```

상태 확인:

```bash
docker compose ps -a
docker network inspect infra-net
```

종료(volume까지 삭제하여 초기화):

```bash
docker compose down -v
```

현재 Compose 파일은 로컬 이미지 이름을 기준으로 합니다.

```text
infra-dns:1.0
infra-web:1.0
infra-ftp:1.0
infra-mail:1.0
infra-nfs:1.0
```

FTP 서비스의 `PASV_ADDRESS=172.30.0.30`은 Compose 통합 검증에서 `test-client`가 내부 Docker 네트워크를 통해 FTP 서버에 접속하기 위한 값입니다.

Docker Hub 이미지 이름은 팀원별 계정이 다를 수 있으므로, 통합 검증에서는 로컬 이미지 기준을 사용합니다.

## 12. Integrated Verification

통합 검증은 `docker compose up -d`로 서버 컨테이너와 `test-client` 컨테이너가 생성된 뒤 진행합니다.

```bash
cd compose
docker compose up -d
docker compose ps -a

docker exec -it test-client sh
```

필요 도구 설치:

```sh
# alpine 계열 test-client를 사용하는 경우
apk add --no-cache bind-tools curl lftp netcat-openbsd nfs-utils

# CentOS/Rocky 계열 test-client를 사용하는 경우
dnf -y install bind-utils curl lftp nmap-ncat nfs-utils
```

### DNS

```sh
nslookup www.example.com
nslookup ftp.example.com
nslookup mail.example.com
nslookup nfs.example.com
nslookup -type=mx example.com
```

정상 기준:

```text
www.example.com  → 172.30.0.20
ftp.example.com  → 172.30.0.30
mail.example.com → 172.30.0.40
nfs.example.com  → 172.30.0.50
example.com MX   → mail.example.com
```

### WEB

```sh
curl http://www.example.com
curl -k https://www.example.com
```

`.htaccess` 적용 여부는 WEB 이미지에서 구성한 테스트 경로를 기준으로 확인합니다.

### FTP

```sh
lftp -e "set ftp:passive-mode true; ls; quit" -u anonymous, ftp://ftp.example.com
```

Real FTP 접속은 구현한 계정 기준으로 확인합니다.

```sh
lftp -e "set ftp:passive-mode true; ls; quit" -u user01,password ftp://ftp.example.com
```

### MAIL

SMTP 수신 테스트:

```sh
printf 'HELO test-client.example.com\r\nMAIL FROM:<tester@example.com>\r\nRCPT TO:<user01@example.com>\r\nDATA\r\nSubject: Integrated mail test\r\n\r\nThis is an integrated mail test.\r\n.\r\nQUIT\r\n' | nc -w 5 mail.example.com 25
```

Web Mail 접속은 브라우저 또는 `curl`을 사용하여 확인합니다.

```sh
curl http://mail.example.com
```

메일 저장 확인은 docker host에서 진행합니다.

```bash
docker exec mymail sh -c 'grep -R "Integrated mail test" /home/user01/Maildir/new'
```

### NFS

NFS 공유 확인:

```sh
showmount -e nfs.example.com
```

NFSv4 마운트 확인:

```sh
mkdir -p /mnt/nfs-test
mount -t nfs4 nfs.example.com:/ /mnt/nfs-test
df -h /mnt/nfs-test
```

## 13. Docker Hub

Docker Hub 업로드는 각자 담당 이미지 또는 개인 구현 결과에 맞게 진행합니다.

예시:

```bash
docker tag infra-web:1.0 <dockerhub-id>/infra-web:1.0
docker push <dockerhub-id>/infra-web:1.0
```

Docker Hub README에는 다음 내용을 포함합니다.

```text
- 이미지 역할
- docker pull
- docker run
- 포트
- volume
- 환경 변수
- 기본 계정 또는 접속 방식
- 설정 변경 위치
- 검증 명령
```

Docker Hub 배포 검증은 통합 검증과 분리합니다.

```text
통합 검증
- 로컬 이미지 기준으로 Compose 실행

Docker Hub 배포 검증
- docker2에서 docker pull
- 단독 실행
- Up 상태와 기본 서비스 응답 확인
```

Docker Hub에 업로드하는 이미지는 특정 IP에 의존하지 않도록 제작합니다.

통합 검증에서 사용하는 172.30.0.x 대역은 `compose/docker-compose.yml` 실행환경에서 부여되는 값이며, 단독 실행 또는 Docker Hub pull 테스트에서는 사용자가 `docker run` 또는 별도 Compose 파일에서 네트워크, 포트, volume, 환경 변수를 지정합니다.

## 14. Optional Script

`scripts/setup-bashrc.sh`는 선택적으로 사용할 수 있는 편의 스크립트입니다.

목적:

```text
- 프롬프트 설정
- vi alias 설정
- Docker alias 설정
```

실행:

```bash
./scripts/setup-bashrc.sh
source ~/.bashrc
```

이 스크립트는 팀원 개인 환경을 강제로 변경하는 것이 아니며, 필요한 경우에만 실행합니다.

## 15. Documentation

최종 문서는 Notion에서 별도로 작성합니다.

문서에는 다음 내용을 포함합니다.

```text
1. 개요
2. 실습 환경
3. 프로젝트 구조
4. WEB 서버
5. FTP 서버
6. DNS 서버
7. MAIL 서버
8. NFS 서버
9. 통합 검증
10. Docker Hub 배포
11. 프로젝트 의의
```

각 서버 장에는 설계 목적, 파일 구조, 주요 설정, 트러블슈팅 기준, 단독 실행 테스트, 검증 결과를 포함합니다.
