
database -open waves -shm -into waves.shm
# -memories      : unpacked 배열 (logic [7:0] mem [0:N]) 포함
# -variables     : SV variable (logic/int 등) 포함
# -packed N      : packed 배열 확장 한계 (bit 수)
# -unpacked N    : unpacked 배열 element 한계
probe -create -shm -all -depth all -memories -variables -dynamic -packed 65536 -unpacked 65536
run

