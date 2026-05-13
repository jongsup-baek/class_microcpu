---
marp: true
theme: konyang
paginate: true
header: "MicroCPU: GitHub Classroom 사용법"
footer: "Copyright 2026. 한국반도체설계(주) KSDC Semi, Jongsup Baek. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU

GitHub Classroom 사용법

<br><br><br><br><br><br>
건양대학교<br>백종섭 교수

---

## 학습 목표

- 🔖 1. GitHub 계정을 생성할 수 있다
- 🔖 2. GitHub Classroom 초대 링크로 개인 레포를 생성할 수 있다
- 🔖 3. 서버에서 Git 초기 설정을 할 수 있다
- 🔖 4. 서버에서 개인 레포를 clone할 수 있다
- 🔖 5. 레포의 lab 폴더 구조를 이해할 수 있다
- 🔖 6. 과제를 완성하고 git push로 제출할 수 있다
- 🔖 7. git 관련 문제를 스스로 해결할 수 있다

---

## 🔖 1. GitHub 가입 (최초 1회)

- https://github.com/signup 접속
- 이메일 입력 → 비밀번호 설정 → Username 입력
  - Username 규칙: 영문, 숫자, 하이픈(-) 사용 가능 (예: honggildong)
- 이메일 인증 코드 확인 후 입력
- 계정 생성 완료

---

## 🔖 2. GitHub Classroom 레포 생성

- Notion 페이지에서 초대 링크를 클릭
  - 초대 링크: https://classroom.github.com/a/vH_E2JJy
- GitHub 로그인 → **Accept this assignment** 클릭
- 잠시 기다리면 개인 레포가 자동 생성됨
  - 레포 이름: `2026-1-microcpu-kyu-본인Username`
  - 예: `2026-1-microcpu-kyu-honggildong`
- 초대 링크는 **1번만 클릭**하면 됨

---

## 🔖 3. 서버에서 Git 초기 설정 (최초 1회)

- 서버 터미널(VS Code 또는 MobaXterm)에서 아래 명령을 입력

```bash
git config --global user.name "본인Username"
```

```bash
git config --global user.email "본인이메일@example.com"
```

```bash
git config --global credential.helper store
```

- GitHub 가입 시 사용한 Username과 이메일을 정확히 입력

---

## 🔖 4. 서버에서 Git Clone (최초 1회)

- 터미널에서 아래 명령을 순서대로 입력

```bash
mkdir ~/work
cd ~/work
git clone https://github.com/ksdcsemi-class/2026-1-microcpu-kyu-본인Username.git
```

- GitHub 사용자명과 비밀번호(또는 토큰) 입력
- clone이 완료되면 레포 폴더로 이동:

```bash
cd 2026-1-microcpu-kyu-본인Username
ls
```

- `lab00-design/`, `lab01-regfile/`, ... `lab12-prog_movsum/` 폴더가 보이면 성공

---

## 🔖 5. 레포 구조

```
2026-1-microcpu-kyu-본인Username/
├── lab00-design/
├── lab01-regfile/
├── lab02-alu/
├── lab03-mux/
├── lab04-pc/
├── lab05-mem/
├── lab06-ir/
├── lab07-sysclk/
├── lab08-ctrl/
├── lab09-core/
├── lab10-prog_ctrl/
├── lab11-prog_arith/
└── lab12-prog_movsum/
```

- lab01 이후 폴더에 `_blank.sv` 파일이 있음 → 이 파일을 완성하는 것이 과제
- lab00-design은 lab 진행 시 설계 파일을 저장하는 폴더

---

## 🔖 6. 과제 제출 흐름

<div class="columns">
<div>

- 터미널에서 아래 명령을 순서대로 입력

```bash
cd ~/work/2026-1-microcpu-kyu-본인Username
```
```bash
git status                            # 변경 파일 확인
git add lab01-regfile/                    # 파일 스테이징
git commit -m "lab01-regfile 완성"        # 커밋
git push                              # GitHub에 업로드
```

- 브라우저에서 GitHub 본인 레포에 파일이 보이면 제출 완료

</div>
<div>

- 매주 반복하는 흐름

```
서버 접속 (VS Code / MobaXterm)
    ↓
해당 lab 폴더의 _blank.sv 수정
    ↓
코드 작성 → 저장
    ↓
시뮬레이션 실행 (xrun)
    ↓
git status → git add → git commit → git push
```

- 수정 후 재제출하려면 동일한 흐름을 반복

</div>
</div>

---

## 🔖 7. 자주 묻는 질문

- **잘못된 파일을 커밋했다**
  - 파일을 수정하고 다시 커밋/푸시하면 됨
  - 과제 제출 기준은 마감일 기준 최종 push

- **레포 폴더를 실수로 삭제했다**
  - 다시 clone하면 됨. GitHub에 push한 내용은 안전하게 보관됨

- **git push가 거부된다**
  - 교수가 레포를 업데이트한 경우 발생
  - `git pull --rebase origin main` 실행 후 다시 `git push`
