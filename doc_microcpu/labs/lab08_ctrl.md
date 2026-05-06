---
marp: true
theme: konyang
paginate: true
header: "Lab 08: Control FSM"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 08: Control FSM

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — control.sv

`control_blank.sv`를 열고 Comment #1 영역에 FSM을 작성한다. state FF + 출력 FF(next-state 기반).

모든 출력이 FF — 글리치 없는 등록된 출력.

<p class="ref">💻 control.sv (코드가 길어 슬라이드 참조)</p>

---

## Step 2: TB — 전체 opcode 검증

<div class="columns">
<div>

- Comment #1: drive_fsm task

```verilog
// Comment #1 : drive_fsm task
task drive_fsm(input opcode_t op);
   ir_opcode = op;
   repeat(8) @(posedge clk);
endtask
```

</div>
<div>

- Comment #2: 전체 opcode 검증

```verilog
// Comment #2 : 전체 opcode 검증
drive_fsm(ADD);
drive_fsm(BRA);
drive_fsm(STA);
drive_fsm(WFR);
```

시뮬레이션하여 각 opcode의 제어 신호를 파형으로 확인한다.

<p class="ref">💻 tb_control.sv</p>

</div>
</div>

---

## Step 4: 완성품 복사

```bash
cd ..
cp cpu_pkg.sv control.sv ../../../design/
```

---

## Step 5: Git Checkin

```bash
git status
git add cpu_pkg.sv control.sv tb_control.sv
git add ../../../design/cpu_pkg.sv ../../../design/control.sv
git commit -m "lab08: control FSM 설계 완료"
```
