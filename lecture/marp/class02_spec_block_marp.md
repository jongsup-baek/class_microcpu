---
marp: true
theme: konyang
paginate: true
header: "Class 02: MicroCPU 블럭 스펙"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Class 02: MicroCPU 블럭 스펙

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## 학습 목표

🔖 2.1 MicroCPU 핀 스펙 — 외부 핀 4개의 역할과 동작을 설명할 수 있다
🔖 2.2 MicroCPU 블럭 다이어그램 — 내부 블럭 구성과 신호 연결을 파악할 수 있다
🔖 2.3 MicroCPU 내부 신호 — 데이터, 주소 — 데이터·주소 신호의 방향과 역할을 설명할 수 있다
🔖 2.4 MicroCPU 내부 신호 — 상태, 제어 — Controller 입출력 신호를 식별할 수 있다
🔖 2.5 명령어 실행 데이터 흐름 — 8-상태 FSM의 각 상태별 동작을 추적할 수 있다
🔖 2.6 명령어 실행 제어 신호 — 상태별 제어 신호 활성화를 읽을 수 있다
🔖 2.7 MicroCPU 구성 블럭 — 모듈명, 인스턴스명, 클럭 도메인을 식별할 수 있다

---

## 2.1 MicroCPU 핀 스펙

> 외부에서는 클럭과 리셋만 제공하고, 프로세서 상태를 halt와 ir_load로 관측한다

<style scoped>
td, th { padding: 10px 12px; }
</style>

| 핀 이름 | 방향 | 폭(비트) | 설명 |
| --- | --- | --- | --- |
| clk_ext | 입력 | 1 | 외부 클럭. 상승 에지 동작.<br>내부에서 2분주하여 clk_sys를 생성하는 기준 클럭이다. |
| rst_n | 입력 | 1 | 비동기 리셋. Active-low.<br>Low 입력 시 모든 내부 레지스터를 0으로 클리어하고, FSM을 초기 상태로 복귀시킨다. |
| halt | 출력 | 1 | 프로세서 정지 표시. Active-high.<br>WFR 명령어 실행 시 high가 되며, 리셋 전까지 유지된다.<br>halt가 High이면 내부 클럭이 정지하여 모든 동작이 멈춘다. |
| ir_load | 출력 | 1 | 명령어 fetch 표시. Active-high.<br>매 명령어의 fetch 단계에서 1사이클 동안 high가 된다.<br>외부에서 실행된 명령어 수를 카운트하거나 명령어 경계를 식별하는 데 사용한다. |

---

## 2.2 MicroCPU 블럭 다이어그램

> cpu_top 내부의 블럭 구성과 데이터 경로. sysclk, cpu_core, MEM 3개 블럭으로 나뉜다

![MicroCPU Block Diagram](../images/microcpu_block.drawio.svg)

---

## 2.3 MicroCPU 내부 신호 — 데이터, 주소

<style scoped>
td, th { padding-left: 6px; padding-right: 6px; }
</style>

> 블럭 간 데이터 신호와 주소 신호를 정리한다. 제어 신호는 2.4에서 다룬다

| 그룹 | 신호 | 폭 | From | To | 설명 |
| --- | --- | --- | --- | --- | --- |
| **데이터** | data_out | 16 | MEM | IR, op_mux | 메모리에서 읽은 명령어 또는 피연산자 데이터를 전달한다. |
| | rd_data | 16 | Register File | ALU, MEM | Rd 값을 ALU의 첫 번째 입력으로 전달한다. STA 시 메모리에 기록한다. |
| | rs_data | 16 | Register File | op_mux | Rs 값을 op_mux에 전달한다. |
| | alu_operand | 16 | op_mux | ALU | 선택된 피연산자를 ALU의 두 번째 입력으로 전달한다. |
| | alu_out | 16 | ALU | Register File | 연산 결과를 Rd에 저장한다. |
| **주소** | ir_rd | 2 | IR | Register File | 목적 레지스터 주소를 전달한다. |
| | ir_rs | 2 | IR | Register File | 소스 레지스터 주소를 전달한다. |
| | ir_addr | 8 | IR | addr_mux, PC | 피연산자 주소 또는 분기 주소를 전달한다. |
| | pc_addr | 8 | PC | addr_mux | 현재 명령어의 메모리 주소를 전달한다. |
| | addr | 8 | addr_mux | MEM | fetch_phase에 따라 pc_addr 또는 ir_addr을 선택하여 전달한다. |
---

## 2.4 MicroCPU 내부 신호 — 상태, 제어

<style scoped>
td, th { padding-left: 6px; padding-right: 6px; }
</style>

> Controller가 생성하는 제어 신호와 Controller에 입력되는 상태 신호를 정리한다

| 그룹 | 신호 | 폭 | From | To | 설명 |
| --- | --- | --- | --- | --- | --- |
| **상태** | ir_opcode | 3 | IR | Controller | 디코딩된 opcode를 전달한다. |
| | ir_mode | 1 | IR | op_mux | mode 비트로 피연산자 소스를 선택한다. |
| | zero | 1 | ALU | Controller | ALU 결과가 0이면 High. BRZ 분기 판단에 사용한다. |
| **제어** | fetch_phase | 1 | Controller | addr_mux | Fetch+Decode 구간이면 high. addr_mux가 pc_addr을 선택한다. |
| | ir_load | 1 | Controller | IR | high일 때 IR이 명령어를 래치한다. |
| | halt | 1 | Controller | sysclk | WFR 실행 시 high. clock gating으로 clk_sys를 정지시킨다. |
| | mem_rd | 1 | Controller | MEM | high일 때 메모리 읽기를 수행한다. |
| | mem_wr | 1 | Controller | MEM | high일 때 메모리 쓰기를 수행한다. |
| | load_reg | 1 | Controller | Register File | high일 때 ALU 결과를 Rd에 저장한다. |
| | load_pc | 1 | Controller | PC | high일 때 ir_addr을 PC에 로드한다. (BRA) |
| | inc_pc | 1 | Controller | PC | high일 때 PC를 1 증가시킨다. |

---

## 2.5 MicroCPU 명령어 실행 — 데이터 흐름

<style scoped>
table { width: 100%; }
td, th { padding: 12px 10px; }
td:nth-child(4), td:nth-child(5) { width: 14%; }
td:nth-child(6) { width: 65%; }
</style>

> 하나의 명령어는 Fetch(S0~S3) + Execute(S4~S7) 8개 상태를 순차적으로 거쳐 실행된다

| FSM | 이름 | 단계 | From | To | 설명 |
| :---: | :---: | :---: | :---: | :---: | --- |
| S0 | INST_ADDR | Fetch | PC | addr_mux | PC 주소를 addr_mux에 전달한다. |
| S1 | INST_FETCH | Fetch | addr_mux | MEM | PC 주소로 메모리 읽기를 시작한다. |
| S2 | INST_LOAD | Fetch | MEM | IR | 메모리에서 읽은 16비트 명령어를 IR에 래치한다. |
| S3 | IDLE | Decode | IR | — | IR이 명령어를 5개 필드로 분리한다. |
| S4 | OP_ADDR | Execute | IR | addr_mux | addr_mux가 ir_addr을 선택한다. 다음 명령어를 위해 PC를 증가시킨다. |
| S5 | OP_FETCH | Execute | addr_mux | MEM | ADD, AND, LDA이면 mem[addr]을 읽는다. 그 외 명령어는 읽지 않는다. |
| S6 | OP_ALU | Execute | regfile, op_mux | regfile, PC | BRZ이면서 rd_data=0이면 건너뛰기, BRA이면 ir_addr을 PC에 로드한다.<br>ADD,AND,LDA,NOT이면 ALU 연산 결과를 Rd에 저장한다. |
| S7 | UPDATE | Execute | regfile | MEM | STA이면 rd_data를 mem[addr]에 기록한다. |

---

## 2.6 MicroCPU 명령어 실행 — 제어 신호

> Fetch phase의 제어 신호는 모든 명령어에서 동일하고, Execute phase의 제어 신호는 opcode에 따라 조건부로 활성화된다

![Control signals](../images/class01_1_8_ctrl_signal_wavedrom.svg)

---

## 2.7 MicroCPU 구성 블럭

<style scoped>
table { width: 100%; }
td, th { padding: 4px 12px; }
td:nth-child(1), th:nth-child(1) { width: 12%; }
td:nth-child(2), th:nth-child(2) { width: 15%; }
td:nth-child(3), th:nth-child(3) { width: 13%; }
td:nth-child(4), th:nth-child(4) { width: 60%; }
</style>

> cpu_top 내부 블럭의 모듈명, 인스턴스명, 역할을 정리한다

**cpu_top**

| 블럭 | 모듈 | 인스턴스 | 설명 |
| --- | --- | --- | --- |
| sysclk | sysclk | u_sysclk | 내부 클럭을 생성하고, WFR 시 클럭을 정지시킨다. |
| MEM | mem | u_mem | 명령어와 데이터를 저장하고, 읽기/쓰기 요청에 응답한다. |
| cpu_core | cpu_core | u_cpu_core | 명령어를 해석하고 실행하는 프로세서 코어이다. |

**cpu_core**

| 블럭 | 모듈 | 인스턴스 | 설명 |
| --- | --- | --- | --- |
| PC | prog_counter | u_pc | 다음에 실행할 명령어의 메모리 주소를 가리킨다. |
| addr_mux | mux2to1 #(8) | u_addrmux | Fetch 시 PC 주소, Execute 시 ir_addr 중 하나를 선택하여 MEM에 전달한다. |
| IR | instr_reg | u_ir | 메모리에서 읽은 명령어를 저장하고, 5개 필드로 분리하여 각 블럭에 전달한다. |
| Register File | regfile | u_regfile | 연산에 사용할 데이터를 저장하고, Rd/Rs를 통해 읽기/쓰기한다. |
| op_mux | mux2to1 #(16) | u_opmux | 메모리 값 또는 Rs 값 중 하나를 선택하여 ALU에 전달한다. |
| ALU | alu | u_alu | Rd와 피연산자로 산술/논리 연산을 수행하고, 결과와 zero 플래그를 출력한다. |
| Controller | control | u_ctrl | 명령어 실행 순서를 제어하고, 각 블럭에 제어 신호를 보낸다. |

