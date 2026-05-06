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

`tb_control_blank.sv`를 열고 Comment #1, #2를 작성한다.

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

<p class="ref">💻 tb_control.sv</p>

</div>
</div>

---

## Step 3: 시뮬레이션

- 시뮬레이션하여 각 opcode의 제어 신호를 파형으로 확인한다.

```bash
cd sim
xrun -f lab08_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  rst_n  state       ir_opcode  mem_rd  ir_load  inc_pc  load_reg  load_pc  mem_wr  halt
----  -----  ----------  ---------  ------  -------  ------  --------  -------  ------  ----
   0      0  INST_ADDR   WFR             0        0       0         0        0       0     0
 100      1  INST_ADDR   WFR             0        0       0         0        0       0     0
 200      1  INST_FETCH  ADD             1        0       0         0        0       0     0    #2
 300      1  INST_LOAD   ADD             1        1       0         0        0       0     0
 400      1  IDLE        ADD             1        1       0         0        0       0     0
 500      1  OP_ADDR     ADD             0        0       1         0        0       0     0
 600      1  OP_FETCH    ADD             1        0       0         0        0       0     0
 700      1  OP_ALU      ADD             1        0       0         1        0       0     0
 800      1  UPDATE      ADD             0        0       0         0        0       0     0
 900      1  INST_ADDR   ADD             0        0       0         0        0       0     0
1000      1  INST_ADDR   BRA             0        0       0         0        0       0     0
1100      1  INST_FETCH  BRA             1        0       0         0        0       0     0
1200      1  INST_LOAD   BRA             1        1       0         0        0       0     0
1300      1  IDLE        BRA             1        1       0         0        0       0     0
1400      1  OP_ADDR     BRA             0        0       1         0        0       0     0
1500      1  OP_FETCH    BRA             0        0       0         0        0       0     0
1600      1  OP_ALU      BRA             0        0       0         0        1       0     0
1700      1  UPDATE      BRA             0        0       0         0        0       0     0
1800      1  INST_ADDR   STA             0        0       0         0        0       0     0
1900      1  INST_FETCH  STA             1        0       0         0        0       0     0
2000      1  INST_LOAD   STA             1        1       0         0        0       0     0
2100      1  IDLE        STA             1        1       0         0        0       0     0
2200      1  OP_ADDR     STA             0        0       1         0        0       0     0
2300      1  OP_FETCH    STA             0        0       0         0        0       0     0
2400      1  OP_ALU      STA             0        0       0         0        0       0     0
2500      1  UPDATE      STA             0        0       0         0        0       1     0
2600      1  INST_ADDR   WFR             0        0       0         0        0       0     0
2700      1  INST_FETCH  WFR             1        0       0         0        0       0     0
2800      1  INST_LOAD   WFR             1        1       0         0        0       0     0
2900      1  IDLE        WFR             1        1       0         0        0       0     0
3000      1  OP_ADDR     WFR             0        0       1         0        0       0     0
3100      1  OP_ADDR     WFR             0        0       1         0        0       0     1
```

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
