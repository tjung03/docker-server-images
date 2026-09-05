# 협업 가이드

[프로젝트 소개](../README.md) · [실행 구성](usage.md#compose-실행-구성)

## 작업과 브랜치

서버별 작업은 `dns/`, `web/`, `ftp/`, `mail/`, `nfs/`에서 진행합니다. Issue를 작업 카드로 사용하고, 개인 이니셜 브랜치에서 작업한 뒤 `main`을 대상으로 Pull Request를 생성합니다.

처음 시작할 때:

```bash
git clone https://github.com/tjung03/docker-server-images.git
cd docker-server-images
git switch main
git pull origin main
git switch -c jth
git push -u origin jth
```

`jth`는 개인 이니셜 예시입니다. 기존 브랜치는 `git switch jth`로 이동하며, 임시 작업은 `jth-temp`처럼 구분합니다.

변경 파일을 확인하여 커밋한 뒤 개인 브랜치에 push합니다. PR에는 작업 내용, 검증 명령과 결과, 후속 확인 사항을 작성하고 변경 내용을 검토한 뒤 병합합니다. `main` 반영은 PR을 통해 진행합니다.

다른 팀원의 작업을 반영할 때는 현재 작업을 먼저 커밋한 뒤 아래 순서를 사용합니다.

```bash
git switch main
git pull origin main
git switch jth
git merge main
git push
```

## 커밋과 PR

커밋 형식은 `<type>(<scope>): <message>`입니다.

| type | 용도 |
|---|---|
| `feat` | 기능·파일 추가 |
| `fix` | 오류 수정 |
| `docs` | 문서 수정 |
| `test` | 테스트·검증 절차 추가 |
| `chore` | 구조·설정 정리 |
| `etc` | 기타 변경 |

scope는 `web`, `ftp`, `dns`, `mail`, `nfs`, `compose`, `readme`를 사용합니다.

```text
feat(nfs): add nfs v4 server config
docs(readme): update server usage
```

Issue·PR 제목은 `[NFS] NFSv4 서버 이미지 구현`처럼 대상을 표시합니다.

## 이미지와 실행 이름

| 대상 | 로컬 이미지 | 컨테이너 |
|---|---|---|
| DNS | `infra-dns:1.0` | `mydns` |
| WEB | `infra-web:1.0` | `myweb` |
| FTP | `infra-ftp:1.0` | `myftp` |
| MAIL | `infra-mail:1.0` | `mymail` |
| NFS | `infra-nfs:1.0` | `mynfs` |

공통 네트워크는 `infra-net`을 사용합니다. 포트와 볼륨은 [Compose 구성표](usage.md#compose-실행-구성)를 따릅니다. 이미지는 특정 통합 IP에 의존하지 않도록 구성하고, 실행 시 필요한 값을 설정합니다.

Docker Hub에 게시할 때는 본인 계정 이름으로 태그를 붙입니다. 다음은 WEB 이미지 게시 절차입니다.

```bash
read -r -p 'Docker Hub 계정: ' DOCKERHUB_USER
test -n "$DOCKERHUB_USER" || exit 1
docker login
docker tag infra-web:1.0 "$DOCKERHUB_USER/infra-web:1.0"
docker push "$DOCKERHUB_USER/infra-web:1.0"
```

## 셸 설정 도우미

[scripts/setup-bashrc.sh](../scripts/setup-bashrc.sh)는 프롬프트, Docker 별칭, 자동완성 설정을 `~/.bashrc`에 중복 없이 추가합니다.

```bash
bash scripts/setup-bashrc.sh
source ~/.bashrc
```

추가되는 `irm`, `crm`, `vrm`, `nrm` 별칭은 각각 호스트의 전체 이미지, 전체 컨테이너, 전체 볼륨, 사용자 네트워크를 정리하는 명령입니다. 실습 환경의 다른 작업에도 영향을 줄 수 있으므로 실행 전에 대상을 확인합니다.
