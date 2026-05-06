---
marp: true
theme: konyang
paginate: true
header: "Lab 09: CPU Core + Top"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 09: CPU Core + Top 조립

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — cpu_core.sv

`cpu_core_blank.sv`를 열고 Comment #1 영역에 블록 인스턴스를 연결한다. design/ 폴더의 완성품을 사용.

인스턴스: u_ir, u_regfile, u_pc, u_opmux, u_alu, u_addrmux, u_ctrl

<p class="ref">💻 cpu_core.sv (코드가 길어 슬라이드 참조)</p>

---

## Step 2: 설계 — cpu_top.sv

`cpu_top_blank.sv`를 열고 Comment #1 영역에 top 인스턴스를 연결한다.

인스턴스: u_sysclk, u_cpu_core, u_mem

<p class="ref">💻 cpu_top.sv</p>

---

## Step 3: TB — halt 대기

`tb_cpu_core_blank.sv`를 열고 Comment #1을 작성한다.

```verilog
// Comment #1 : halt 대기
repeat (100) begin
   @(posedge clk_ext);
   if (halt) break;
end
```

메모리를 0으로 초기화 → 첫 명령어가 WFR(=0) → halt.

<p class="ref">💻 tb_cpu_core.sv</p>

---

## Step 4: 시뮬레이션

- 시뮬레이션하여 컴파일 + halt 동작을 확인한다.

```bash
cd sim
xrun -f lab09_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  rst_n  clk_sys  halt  state       addr  mem_rd  mem_wr
----  -----  -------  ----  ----------  ----  ------  ------
  50      0        0     0  INST_ADDR     00       0       0
 150      0        0     0  INST_ADDR     00       0       0
 250      1        1     0  INST_FETCH    00       1       0    #1
 350      1        0     0  INST_FETCH    00       1       0
 450      1        1     0  INST_LOAD     00       1       0
 550      1        0     0  INST_LOAD     00       1       0
 650      1        1     0  IDLE          00       1       0
 750      1        0     0  IDLE          00       1       0
 850      1        1     1  OP_ADDR       00       0       0
```

---

## Step 5: 완성품 복사

```bash
cd ..
cp cpu_core.sv cpu_top.sv ../../design/
```

---

## Step 6: Git Checkin

```bash
git status
git add cpu_core.sv cpu_top.sv tb_cpu_core.sv
git add ../../design/cpu_core.sv ../../design/cpu_top.sv
git commit -m "lab09: cpu_core+cpu_top 조립 완료"
```
