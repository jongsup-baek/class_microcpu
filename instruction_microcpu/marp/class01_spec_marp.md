---
marp: true
theme: konyang
paginate: true
header: "Class 01: MicroCPU 스펙"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Class 01: MicroCPU 스펙

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## 1.1 MicroCPU 핀 스펙

- cpu_top 모듈의 외부 인터페이스 (4핀, SimpleCPU와 동일)

| 방향 | 핀 | 폭 | Active | 설명 |
| --- | --- | --- | --- | --- |
| input | clk_master | 1 | posedge | 시스템 클럭. 내부 4-bit counter의 기준 클럭으로 사용되며, 이 클럭으로부터 clk_core, clk_cntrl, clk_alu, sel_fetch_pc, clk_mem 5개의 phase 클럭이 생성된다. |
| input | rst_n | 1 | low | 비동기 리셋. low 입력 시 클럭과 무관하게 모든 내부 레지스터를 0으로 클리어하고, FSM을 초기 상태로 복귀시킨다. |
| output | halt | 1 | high | 프로세서 정지 표시. HALT 명령어(opcode 000) 실행 시 high가 되며, 리셋 전까지 유지된다. 테스트벤치에서 이 신호를 감시하여 프로그램 종료를 판단한다. |
| output | ir_load | 1 | high | 명령어 fetch 관측 신호. 매 명령어 fetch 단계에서 1사이클 동안 high가 된다. 이 신호를 카운트하여 실행된 명령어 수를 측정하거나, 명령어 경계를 식별하는 데 사용한다. |

---

## 1.2 MicroCPU 블럭 다이어그램

- SimpleCPU 대비 변경: AC -> Register File(R0-R3), Operand MUX 추가
- 블럭 연결: PC -> Address MUX -> MEM -> IR -> decode -> Register File -> ALU -> Register File

| 블럭 | 입력 | 출력 | 변경 |
| --- | --- | --- | --- |
| sys_clk | clk_master | 5개 phase 클럭 | 동일 |
| PC | inc_pc, load_pc, ir_data | pc_addr(8b) | 5b -> 8b |
| Address MUX | pc_addr, ir_data, sel_fetch_pc | addr(8b) | 5b -> 8b |
| MEM | addr, mem_rd, mem_wr, data_in | data_out(16b) | 32x8 -> 256x16 |
| IR | data_out, load_ir | ir_opcode, ir_mode, ir_rd, ir_rs, ir_data | 8b -> 16b |
| Register File | ir_rd, ir_rs, alu_out, load_reg | rd_data(16b), rs_data(16b) | 신규 (AC 대체) |
| Operand MUX | data_out, rs_data, ir_mode | alu_operand(16b) | 신규 |
| ALU | rd_data, alu_operand, opcode | alu_out(16b), zero | 8b -> 16b |
| Controller | ir_opcode, zero | 7개 제어 신호 | load_ac -> load_reg |

---

## 1.3 MicroCPU 명령어 구조

<style scoped>
td, th { padding-left: 6px; padding-right: 6px; }
</style>

- 16비트 명령어 형식 (SimpleCPU 8비트에서 확장)

| 비트 | 15-13 | 12 | 11-10 | 9-8 | 7-0 |
| --- | --- | --- | --- | --- | --- |
| 필드 | opcode | mode | rd | rs | data |
| 폭 | 3b | 1b | 2b | 2b | 8b |
| 용도 | 연산 코드 | 주소 지정 방식 | 목적 레지스터 | 소스 레지스터 | 메모리 주소 |

- mode=0 (메모리 모드): data[7:0]이 메모리 주소로 사용된다. ALU의 두 번째 입력은 mem[data]이다
- mode=1 (레지스터 모드): rs[9:8]이 소스 레지스터를 선택한다. ALU의 두 번째 입력은 reg[rs]이다
- rd[11:10]: R0(00), R1(01), R2(10), R3(11)
- mode 비트 하나가 Operand MUX를 제어하여 데이터패스 전체를 전환한다

---

## 1.4 MicroCPU 명령어 세트 (ISA)

- 3비트 opcode로 8개 명령어를 정의한다 (SimpleCPU와 동일 인코딩)

| Opcode | 이름 | 인코딩 | mode=0 (메모리) | mode=1 (레지스터) |
| --- | --- | --- | --- | --- |
| HALT | Halt | 000 | 프로세서 정지 | 프로세서 정지 |
| BRZ | Branch if Zero | 001 | Rd=0이면 다음 명령어 건너뛰기 | (동일) |
| ADD | Add | 010 | Rd = Rd + mem[data] | Rd = Rd + Rs |
| AND | And | 011 | Rd = Rd & mem[data] | Rd = Rd & Rs |
| SUB | Subtract | 100 | Rd = Rd - mem[data] | Rd = Rd - Rs |
| LDA | Load | 101 | Rd = mem[data] | Rd = Rs (MOV) |
| STA | Store | 110 | mem[data] = Rd | (reserved) |
| BRA | Branch Always | 111 | PC = data | (reserved) |

- zero 플래그: `~(|Rd)` — BRZ에서 사용하는 Rd 레지스터의 combinational zero check
- BRZ/BRA/HALT/STA는 mode 비트를 무시한다

---

## 1.5 MicroCPU 명령어 실행 — 데이터 흐름

- 하나의 명령어는 8개 FSM 상태를 순차적으로 거쳐 실행된다 (SimpleCPU와 동일)

| 상태 | 이름 | 소스 | 타겟 | 설명 |
| --- | --- | --- | --- | --- |
| S0 | INST_ADDR | PC | MUX | 명령어 주소를 출력한다 |
| S1 | INST_FETCH | MUX | MEM | sel_fetch_pc=1, PC 주소로 명령어를 읽는다 |
| S2 | INST_LOAD | MEM | IR | 16비트 명령어를 IR에 저장한다 |
| S3 | IDLE | IR | — | opcode, mode, rd, rs, data로 분리한다 |
| S4 | OP_ADDR | IR | MUX | 피연산자 주소를 출력한다. PC += 1 |
| S5 | OP_FETCH | MUX | MEM | sel_fetch_pc=0, IR의 data[7:0] 주소로 피연산자를 읽는다 |
| S6 | ALU_OP | Rd, MEM/Rs | ALU | mode에 따라 mem[data] 또는 Rs를 사용하여 연산한다 |
| | | | Rd | ADD/AND/SUB/LDA: 결과를 Rd에 저장한다 |
| | | | PC | BRA: data를 PC에 로드. BRZ&zero: PC += 1 |
| S7 | UPDATE | Rd | MEM | STA: Rd 값을 메모리에 기록한다 |

---

## 1.6 MicroCPU 명령어 실행 — 제어 신호

<style scoped>
td, th { padding-left: 6px; padding-right: 6px; }
</style>

- Controller(Mealy FSM)가 현재 상태, opcode, zero 플래그에 따라 출력하는 제어 신호

| 상태 | mem_rd | load_ir | load_reg | inc_pc | load_pc | mem_wr | halt | 예시: ADD R1,mem[0x80] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S0 INST_ADDR | | | | | | | | PC의 주소를 MUX 입력으로 전달 |
| S1 INST_FETCH | 1 | | | | | | | PC 주소로 MEM 읽기 사이클 |
| S2 INST_LOAD | 1 | 1 | | | | | | MEM 데이터 준비, load_ir 활성 |
| S3 IDLE | 1 | 1 | | | | | | IR에 명령어 저장, 필드 디코딩 |
| S4 OP_ADDR | | | | 1 | | | HALT | PC 증가. data=0x80을 MUX로 전달 |
| S5 OP_FETCH | aluop | | | | | | | MEM 0x80번지 읽기 사이클 |
| S6 ALU_OP | aluop | | aluop | BRZ&zero | BRA | | | R1 + mem[0x80] 연산, 결과를 R1에 저장 |
| S7 UPDATE | | | | | | STA | | ADD이므로 갱신 없음 |

- aluop = ADD, AND, SUB, LDA 중 하나일 때 1
- load_ac(SimpleCPU) -> load_reg(MicroCPU)로 변경

---

## 1.7 MicroCPU 구성 블럭

| 블럭 | 모듈 | 설명 |
| --- | --- | --- |
| **cpu_top** | | |
| sys_clk | sys_clk | 클럭 생성기. SimpleCPU와 동일한 5-phase 구조 |
| MEM | mem | 256x16 동기 메모리. 명령어와 데이터를 동일 공간에 저장한다 |
| **cpu_core** | | |
| PC | counter_prog | 8-bit Program Counter. 매 명령어마다 자동 증가한다 |
| Address MUX | addr_mux #(8) | 주소 멀티플렉서. PC 주소(fetch)와 IR data(operand) 중 하나를 선택한다 |
| IR | register_core | 16-bit Instruction Register. opcode, mode, rd, rs, data로 분리한다 |
| Register File | register_file | 4x16-bit 레지스터 파일(R0-R3). SimpleCPU의 단일 AC를 대체한다 |
| Operand MUX | addr_mux #(16) | mode bit에 따라 메모리 데이터 또는 Rs 레지스터 값을 선택한다 |
| ALU | alu | 16-bit 산술/논리 연산기. Rd와 operand를 입력받아 연산한다 |
| Controller | control | 8-상태 Mealy FSM. opcode를 입력받아 동작 타이밍을 제어한다 |

---

## 1.8 sys_clk 블럭

- SimpleCPU와 동일한 5-phase 클럭 구조. 16 master 사이클 = 1 명령어 주기

| 신호 | 유형 | 생성식 | 목적지 | 설명 |
| --- | --- | --- | --- | --- |
| clk_mem | clock | count[0] | MEM | 메모리 읽기/쓰기 클럭. clk_cntrl과 역위상이다. |
| clk_cntrl | clock | ~count[0] | Controller | FSM 상태 전이 클럭. clk_master의 2배 주기로 토글된다. |
| clk_core | clock | count[1] | Register File, IR, PC | 레지스터 동기 클럭. clk_master의 4배 주기로 토글된다. |
| clk_alu | clock | count[3:1]==3'b110 | ALU | ALU 연산 트리거. count=12~13에서 high 펄스가 발생한다. |
| sel_fetch_pc | level | ~count[3] | Address MUX | 주소 선택 레벨 신호. high=PC 주소(count 0~7), low=IR 주소(count 8~15). |

---

## Thank You

🔖 1.1 MicroCPU 핀 스펙
🔖 1.2 MicroCPU 블럭 다이어그램
🔖 1.3 MicroCPU 명령어 구조
🔖 1.4 MicroCPU 명령어 세트 (ISA)
🔖 1.5 MicroCPU 명령어 실행 — 데이터 흐름
🔖 1.6 MicroCPU 명령어 실행 — 제어 신호
🔖 1.7 MicroCPU 구성 블럭
🔖 1.8 sys_clk 블럭
