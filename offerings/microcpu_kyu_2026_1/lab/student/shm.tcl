
database -open waves -shm -into waves.shm
# -memories      : unpacked 배열 (logic [7:0] mem [0:N]) 포함
# -variables     : SV variable (logic/int 등) 포함
# -packed N      : packed 배열 확장 한계 (bit 수)
# -unpacked N    : unpacked 배열 element 한계
probe -create -shm -all -depth all -memories -variables -dynamic -packed 65536 -unpacked 65536
# assertion pass/fail 기록 (SimVision Assertion Browser에서 확인)
# -assertions는 -all, -variables와 동시 사용 불가 → 별도 probe 필요
probe -create -shm -depth all -assertions
run

