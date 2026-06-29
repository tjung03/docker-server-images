# docker-server-images

`docker-server-images`는 DNS, WEB, FTP, MAIL 서버를 Docker 이미지로 제작하고, Docker Compose 기반 통합 실행으로 검증하는 팀 프로젝트입니다.

이 저장소는 각 서버 이미지를 같은 기준으로 제작하기 위한 협업 공간입니다. `main` 브랜치에는 공통 구조와 합의된 결과물을 유지하고, 개인 작업은 각자 브랜치에서 진행한 뒤 Pull Request를 통해 반영합니다.

## 1. 프로젝트 개요

이 프로젝트의 목표는 서버별 Docker 이미지를 직접 제작하고, 각 이미지를 단독 실행 및 통합 실행 환경에서 검증하는 것입니다.

구성 대상은 다음과 같습니다.

| Server | Image Name       | Container Name | Role                         |
| ------ | ---------------- | -------------- | ---------------------------- |
| DNS    | `infra-dns:1.0`  | `mydns`        | `example.com` 내부 DNS zone 제공 |
| WEB    | `infra-web:1.0`  | `myweb`        | nginx 기반 정적 웹 서버             |
| FTP    | `infra-ftp:1.0`  | `myftp`        | anonymous FTP 서버             |
| MAIL   | `infra-mail:1.0` | `mymail`       | Postfix 기반 SMTP 수신 서버        |

통합 실행은 `compose/docker-compose.yml`을 기준으로 합니다.

## 2. 저장소 구조

```text
docker-server-images
├─ README.md
├─ .gitignore
├─ dns
├─ web
├─ ftp
├─ mail
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
```

README 파일은 제출 문서가 아닙니다. 제출 문서는 Notion에서 별도로 작성합니다.

## 3. 공통 이름 기준

통합 실행을 위해 이미지 이름, 컨테이너 이름, 네트워크 이름, volume 이름은 아래 기준을 사용합니다.

### Image

```text
infra-dns:1.0
infra-web:1.0
infra-ftp:1.0
infra-mail:1.0
```

### Container

```text
mydns
myweb
myftp
mymail
```

### Network

```text
infra-net
```

### Volume

```text
web-html
ftp-pub
mail-home
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
test-client : 172.30.0.100
```

DNS zone 파일의 A/MX 레코드는 위 IP 기준과 일치해야 합니다.

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
git commit -m "feat(web): add nginx Dockerfile" -m "Modify volume path"
```
(첫번째 m 옵션은 제목, 두번째 m 옵션은 내용)

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
git commit -m "feat(web): add nginx Dockerfile"
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

일반 작업에서는 `main`으로 이동한 뒤 `git pull origin main`을 사용(원격main->로컬main)하고, 개인 브랜치에서 `git merge main`을 사용(로컬main->로컬branch)하는 흐름으로 통일한다.

### 5-8. commit 로그 확인

기본 로그 확인:

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
git commit -m "feat(web): add nginx Dockerfile"
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
[WEB] nginx 서버 이미지 구현
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
(다른 팀원)
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
```

### Example

```text
feat(web): add nginx Dockerfile
feat(ftp): add vsftpd config
feat(dns): add example.com zone file
feat(mail): add postfix main config
fix(ftp): update passive port range
docs(readme): update branch workflow
test(dns): add nslookup check command
chore(compose): update service names
etc: update repository settings
```

## 7. Issue / Pull Request 사용 방식

Issue는 작업 카드 용도로 사용합니다.

초기 Issue 예시는 다음과 같습니다.

```text
[WEB] nginx 서버 이미지 구현
[FTP] vsftpd anonymous FTP 서버 이미지 구현
[DNS] BIND example.com zone 구성
[MAIL] Postfix SMTP 수신 서버 구성
[COMPOSE] 통합 실행 기준 구성
[README] 협업 가이드 정리
```

Pull Request 제목은 아래 형식을 권장합니다.

```text
[WEB] nginx 서버 이미지 구현
[FTP] vsftpd anonymous FTP 서버 이미지 구현
[DNS] BIND DNS 서버 이미지 구현
[MAIL] Postfix SMTP 수신 서버 이미지 구현
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
- compose/docker-compose.yml의 서비스 이름과 이미지 이름을 기준으로 통합 실행을 맞춥니다.
- entrypoint.sh에는 필요한 경우 간단한 주석을 작성합니다.
- 설정 파일은 동작에 필요한 값을 중심으로 작성합니다.
```

서버별 세부 구현 방식은 각 담당자가 진행하되, 최종 통합 실행이 가능하도록 이미지 이름, 포트, volume, network 기준은 맞추는 것을 권장합니다.

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
example.com MX    → mail.example.com
```

### WEB

```text
작업 위치        : web/
이미지 이름      : infra-web:1.0
컨테이너 이름    : myweb
서비스 포트      : 80/tcp
테스트 호스트 포트: 8080:80
volume           : web-html:/usr/share/nginx/html
통합 IP          : 172.30.0.20
```

### FTP

```text
작업 위치        : ftp/
이미지 이름      : infra-ftp:1.0
컨테이너 이름    : myftp
제어 포트        : 21/tcp
passive port     : 21100-21110/tcp
테스트 호스트 포트: 2121:21
volume           : ftp-pub:/var/ftp/pub
접속 계정        : anonymous
통합 IP          : 172.30.0.30
```

### MAIL

```text
작업 위치        : mail/
이미지 이름      : infra-mail:1.0
컨테이너 이름    : mymail
서비스 포트      : 25/tcp
테스트 호스트 포트: 2525:25
volume           : mail-home:/home
기본 수신 사용자  : user01@example.com, user02@example.com
통합 IP          : 172.30.0.40
```

## 10. Build Usage

각 서버 이미지는 프로젝트 루트에서 빌드합니다.

```bash
docker build -t infra-web:1.0 ./web
docker build -t infra-ftp:1.0 ./ftp
docker build -t infra-dns:1.0 ./dns
docker build -t infra-mail:1.0 ./mail
```

이미지 확인:

```bash
docker images | grep infra-
```

정상 기준:

```text
infra-web
infra-ftp
infra-dns
infra-mail
```

## 11. Compose Integrated Run

`compose/docker-compose.yml`은 최종 통합 실행 기준 파일입니다.

Compose 파일은 각 서버 이미지 제작을 대체하지 않습니다. 각 서버 디렉토리의 Dockerfile로 이미지를 만든 뒤, Compose를 사용하여 DNS, WEB, FTP, MAIL 서버를 하나의 Docker 네트워크에서 실행합니다.

통합 실행은 모든 서버 이미지가 준비된 뒤 진행합니다.

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
```

Docker Hub 이미지 이름은 팀원별 계정이 다를 수 있으므로, 최종 통합 검증에서는 로컬 이미지 기준을 사용합니다.

## 12. Integrated Verification

통합 검증은 `docker compose up -d`로 서버 컨테이너와 `test-client` 컨테이너가 생성된 뒤 진행합니다.

```bash
cd compose
docker compose up -d
docker compose ps -a

docker exec -it test-client sh
```

필요 도구 설치:
**test-client 이미지를 `alpine:3.23`으로 잡았기 때문에** `apk add` 사용.
```sh
# alpine:3.23` 이미지를 사용하는 경우
apk add --no-cache bind-tools curl lftp netcat-openbsd
# CentOS/Rocky 계열의 경우
dnf -y install bind-utils curl lftp nmap-ncat
```

### DNS

```sh
nslookup www.example.com
nslookup ftp.example.com
nslookup mail.example.com
nslookup -type=mx example.com
```

정상 기준:

```text
www.example.com  → 172.30.0.20
ftp.example.com  → 172.30.0.30
mail.example.com → 172.30.0.40
example.com MX   → mail.example.com
```

### WEB

```sh
curl http://www.example.com
```

### FTP

```sh
lftp -e "set ftp:passive-mode true; cd pub; ls; get WelcomeToMyFTPServer.txt; quit" -u anonymous, ftp://ftp.example.com
```

### MAIL

```sh
printf 'HELO test-client.example.com\r\nMAIL FROM:<tester@example.com>\r\nRCPT TO:<user01@example.com>\r\nDATA\r\nSubject: Integrated mail test\r\n\r\nThis is an integrated mail test.\r\n.\r\nQUIT\r\n' | nc -w 5 mail.example.com 25
```

메일 저장 확인은 docker host에서 진행합니다.

```bash
docker exec mymail sh -c 'grep -R "Integrated mail test" /home/user01/Maildir/new'
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
8. 통합 검증
9. Docker Hub 배포
10. 프로젝트 의의
```

각 서버 장에는 설계 목적, 파일 구조, 주요 설정, 트러블슈팅 기준, 단독 실행 테스트, 검증 결과를 포함합니다.
