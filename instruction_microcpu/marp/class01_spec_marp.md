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

## 학습 목표

- MicroCPU의 전체 아키텍처와 설계 특징을 이해한다
- 16비트 명령어 구조와 mode 비트의 역할을 이해한다
- 8개 명령어(ISA)의 동작을 설명할 수 있다
- 외부 인터페이스(핀 스펙)를 이해한다
- 내부 블럭 구성과 데이터 경로를 파악한다
- 8-상태 FSM 기반 명령어 실행 흐름을 추적할 수 있다
- 각 블럭의 입출력 신호와 타이밍 관계를 분석할 수 있다

---

## 1.1 MicroCPU 아키텍처

> MicroCPU는 16비트 명령어와 16비트 데이터를 사용하는 16비트 프로세서이다

| 항목 | 스펙 | 설명 |
| --- | --- | --- |
| 워드 폭 | 16비트 | 메모리, 명령어, 레지스터, ALU 모두 16비트이다.<br>폰 노이만 구조이므로 명령어와 데이터가 같은 폭을 공유한다. |
| 명령어 구조 | 5필드, 16비트 | opcode(3b) + mode(1b) + rd(2b) + rs(2b) + data(8b).<br>하나의 명령어 안에 연산, 주소 지정 방식, 레지스터 2개, 메모리 주소를 모두 인코딩한다. |
| 메모리 구조 | 폰 노이만 | 명령어와 데이터가 동일한 256×16 메모리를 공유한다. |
| 레지스터 | 4×16비트 (R0~R3)<br>2R + 1W 포트 | Rd가 연산의 첫 번째 입력이자 결과 저장 대상이다.<br>4개의 값을 레지스터에 동시에 유지할 수 있다. |
| 명령어 세트 | 3비트 opcode, 8개 | 제어(WFR), 분기(BRZ, BRA), 데이터 이동(LDA, STA), 산술/논리(ADD, AND, NOT). |
| 주소 지정 | Direct, Register | `op_memrd`(ADD, AND, LDA)만 mode 비트로 Direct/Register를 전환한다.<br>나머지 명령어는 mode에 무관하다.<br>Immediate, Indirect, Indexed는 지원하지 않는다. |
| 클럭 | 단일 clk_sys | clk_ext를 2분주. halt 시 clock gating으로 정지. |
| 실행 구조 | 8 clk_sys/명령어<br>Fetch + Execute 2-phase | **Fetch**(S0~S3): 명령어를 읽어 IR에 저장하고 디코딩한다.<br>**Execute**(S4~S7): 피연산자 접근 + 연산 + 결과 저장. |

---

## 1.2 MicroCPU 명령어 구조

> 16비트 명령어 안에 mode 비트 하나를 두어, 메모리 모드와 레지스터 모드를 전환한다

![MicroCPU Instruction Format](../images/microcpu_inst_format.svg)

| 필드 | 비트 | 이름 | 설명 |
| --- | --- | --- | --- |
| opcode | [15:13] | 연산 코드<br>(Operation Code) | 8개 명령어를 인코딩한다. |
| mode | [12] | 주소 지정 방식<br>(Addressing Mode) | op_mux의 sel 입력을 제어한다.<br>**mode=0 (메모리 모드)**: data[7:0]을 메모리 주소로 사용하여 mem[data]를 ALU에 전달한다.<br>**mode=1 (레지스터 모드)**: rs가 지정한 레지스터 값을 ALU에 전달한다. |
| rd | [11:10] | 목적 레지스터<br>(Destination Register) | R0(00), R1(01), R2(10), R3(11).<br>ALU 연산의 첫 번째 입력이자 결과 저장 대상이다. |
| rs | [9:8] | 소스 레지스터<br>(Source Register) | mode=1일 때 ALU의 두 번째 입력으로 사용된다.<br>mode=0일 때는 무시된다. |
| data | [7:0] | 주소<br>(Address) | 8비트 주소 필드. `op_memrd`의 Direct 모드에서 메모리 주소로 사용된다.<br>Register 모드에서는 사용되지 않는다. |

---

## 1.3 MicroCPU 명령어 세트 (ISA: Instruction Set Architecture)

> 3비트 opcode로 8개 명령어를 정의하며, mode 비트에 따라 피연산자 소스가 달라진다

| 그룹 | Opcode | 이름 | 인코딩 | Direct 모드 | Register 모드 | Note |
| --- | --- | --- | --- | --- | --- | --- |
| **제어** | WFR | Wait For Reset | 000 | 프로세서 정지 | <span class="rtl">프로세서 정지</span> | clock gating으로 전체 정지. rst_n으로만 해제 |
| **분기** | BRZ | Branch if Zero | 001 | Rd=0이면 PC += 1 | <span class="rtl">Rd=0이면 PC += 1</span> | 유일한 조건 분기. Rd가 0이면 다음 명령어를 건너뛴다 |
| | BRA | Branch Always | 010 | PC = data | <span class="rtl">PC = data</span> | 무조건 분기. data[7:0]을 PC에 로드 |
| **데이터 이동** | LDA | Load | 011 | Rd = mem[data] | Rd = Rs | Register 모드에서는 레지스터 간 복사 |
| | STA | Store | 100 | mem[data] = Rd | <span class="rtl">mem[data] = Rd</span> | Rd 값을 메모리에 저장 |
| **산술/논리** | ADD | Add | 101 | Rd = Rd + mem[data] | Rd = Rd + Rs | 2's complement 덧셈 |
| | AND | And | 110 | Rd = Rd & mem[data] | Rd = Rd & Rs | 비트 단위 논리곱 |
| | NOT | Not | 111 | Rd = ~Rd | <span class="rtl">Rd = ~Rd</span> | 단항 연산. 메모리 읽기 불필요 |

- `op_memrd` (ADD, AND, LDA): mode 구분이 있다. Direct/Register에 따라 피연산자 소스가 달라진다
- `!op_memrd` (WFR, BRZ, BRA, STA, NOT): mode에 무관하다

---

## 1.4 제어 흐름 프로그래밍

> BRZ(조건 skip)와 BRA(무조건 분기) 2개 명령어로 모든 제어 흐름을 구현한다. 구현 가능한 프로그래밍 구문은 if-then, if-else, while, for, do-while 등 이다



<div class="columns">
<div>

**if-else**
BRZ로 skip 후 BRA로 ELSE로 점프한다. THEN 끝에 BRA로 합류한다.
```c
if (R0 == 0) R1 = mem[0x80];
else         R1 = mem[0x81];
```
```
0x0F  ...                // 이전 코드에서 진행
0x10  BRZ R0             // R0=0? → 0x12(THEN)
0x11  BRA 0x14           // R0≠0  → 0x14(ELSE)
0x12  LDA R1, mem[0x80]  // THEN: R1 = mem[0x80]
0x13  BRA 0x15           // → 0x15
0x14  LDA R1, mem[0x81]  // ELSE: R1 = mem[0x81]
0x15  ...                // 다음 코드 계속
```

**if-then**
ELSE가 없으면 BRA 없이 BRZ + skip 1줄로 구현한다.

</div>
<div>

**while 루프**
BRZ로 탈출 조건 검사, BRA로 반복한다.
```c
while (R0 != 0) R0 -= 1;
```
```
0x0F  ...                // 이전 코드에서 진행
0x10  BRZ R0             // R0=0? → 0x12(탈출)
0x11  BRA 0x14           // R0≠0  → 0x14
0x12  ADD R0, mem[0x82]  // R0 = R0 + (-1)
0x13  BRA 0x10           // → 0x10(반복)
0x14  ...                // 다음 코드 계속
```

**for 루프**
카운터 초기화 후 while과 동일한 패턴으로 구현한다.

**do-while**
본문을 먼저 실행하고 끝에 BRZ + BRA로 반복 여부를 판단한다.

</div>
</div>

---

## 1.5 산술/논리 프로그래밍

> 상수 테이블과 NOT+ADD 조합으로 뺄셈을 포함한 모든 산술 연산을 수행한다. 구현 가능한 프로그래밍 구문은 덧셈, 뺄셈, 증가, 감소, 비트 반전, 비트 마스킹, 변수 대입/저장 등 이다.

<div class="columns">
<div>

**덧셈 / 증가**
ADD로 직접 수행한다. 증가는 상수 1을 ADD.
```
0x10  ADD R0, mem[0x81]  // R0 = R0 + 1
```

**뺄셈 (A - B)**
NOT + ADD(1)로 -B를 만들고 ADD로 A + (-B).

```
0x11  NOT R1             // R1 = ~R1
0x12  ADD R1, mem[0x81]  // R1 = ~R1 + 1 = -R1
0x13  ADD R0, R1         // R0 = R0 + (-R1)
```

**감소 (R0 -= 1)**
상수 -1(0xFFFF)을 메모리에 저장해두고 ADD 한 줄로 감소한다.

```
0x14  ADD R0, mem[0x82]  // R0 = R0 + (-1)
```



</div>
<div>

**상수 테이블**
자주 쓰는 상수(0, 1, -1 등)를 메모리에 미리 저장한다.


```
@80
0000000000000000   // 0x80: 상수 0
0000000000000001   // 0x81: 상수 1
1111111111111111   // 0x82: 상수 -1
0000000011111111   // 0x83: 마스크 0x00FF
```

**비트 반전**
NOT으로 전체 비트를 반전한다.

```
0x15  NOT R0             // R0 = ~R0
```


**비트 마스킹**
원하는 비트 위치에 1을 둔 마스크를 AND하여 특정 비트만 추출한다.
```
0x16  AND R0, mem[0x83]  // R0 = R0 & 0x00FF
```


</div>
</div>

---

## 복습

- MicroCPU는 16비트 명령어와 16비트 데이터를 사용하는 폰 노이만 구조의 16비트 프로세서이다
- 16비트 명령어는 opcode(3b), mode(1b), rd(2b), rs(2b), data(8b) 5개 필드로 구성된다
- 8개 명령어를 4그룹으로 분류한다. `op_memrd`(ADD, AND, LDA)만 mode에 따라 Direct/Register를 전환한다
- BRZ와 BRA 2개 명령어로 if-else, while, for 등 모든 제어 흐름을 구현할 수 있다
- 상수 테이블을 메모리에 저장하고, NOT+ADD 조합으로 뺄셈을 포함한 모든 산술 연산을 수행한다

---

## Thank You

🔖 1.1 MicroCPU 아키텍처
🔖 1.2 MicroCPU 명령어 구조
🔖 1.3 MicroCPU 명령어 세트 (ISA)
🔖 1.4 제어 흐름 프로그래밍
🔖 1.5 산술/논리 프로그래밍
