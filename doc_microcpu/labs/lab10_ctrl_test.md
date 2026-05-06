---
marp: true
theme: konyang
paginate: true
header: "Lab 10: 제어 검증 프로그램"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 10: 제어 검증 프로그램 (test_ctrl)

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: test_ctrl.dat — BRA 검증

`test_ctrl_blank.dat`를 열고 ISA 레퍼런스와 실행 흐름을 참고하여 Comment #1 영역에 바이너리를 작성한다.

```
// Comment #1. BRA 검증
@00
010_0_00_00_00000101    //  0x00  BRA 0x05
000_0_00_00_00000000    //  0x01  WFR
...
010_0_00_00_00100000    //  0x05  BRA 0x20
```

시뮬레이션하여 BRA 동작을 확인한다.

---

## Step 2: test_ctrl.dat — LDA + BRZ 검증

Comment #2 영역에 바이너리를 추가하고 다시 시뮬레이션한다.

```
// Comment #2. LDA + BRZ 검증
@20
011_0_00_00_10000000    //  0x20  LDA R0,[0x80]
001_0_00_00_00000000    //  0x21  BRZ R0
...
010_0_00_00_01000000    //  0x25  BRA 0x40
```

---

## Step 3: test_ctrl.dat — STA 검증

Comment #3 영역에 바이너리를 추가하고 다시 시뮬레이션한다.

```
// Comment #3. STA 검증
@40
100_0_00_00_10000010    //  0x40  STA [0x82],R0
...
000_0_00_00_00000000    //  0x46  WFR  모든 테스트 통과!
```

---

## Step 4: Git Checkin

```bash
git status
git add program_code/test_ctrl.dat tb_cpu_top.sv
git commit -m "lab10: test_ctrl 프로그램 작성 완료"
```
