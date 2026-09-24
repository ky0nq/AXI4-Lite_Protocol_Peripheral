# GitHub push 절차 (로컬 PC에서 실행)

repo에 이미 README.md 1커밋이 있으므로 clone → 복사 → push 순서로 진행합니다.

```bash
# 1. 기존 repo clone
git clone https://github.com/ky0nq/AXI4-Lite_Protocol_Peripheral.git
cd AXI4-Lite_Protocol_Peripheral

# 2. 이 zip의 내용물을 clone한 폴더에 복사 (README.md는 새 것으로 덮어쓰기)
#    Windows 탐색기: zip 안의 파일/폴더 전체 선택 → 붙여넣기 → "덮어쓰기"
#    (PUSH_GUIDE.md는 복사하지 않아도 됩니다)

# 3. 확인
git status

# 4. 커밋 & push
git add .
git commit -m "Add AXI4-Lite peripheral IPs, MicroBlaze SW stack, UVM GPIO testbench"
git push origin main
```

## 이후 정리 권장사항 (선택)
- GitHub repo 설정 → About → Description / Topics 추가
  - 예: `fpga`, `verilog`, `axi4-lite`, `microblaze`, `vivado`, `vitis`, `uvm`, `basys3`
- 완료보고서 PDF, 블록다이어그램 이미지가 있으면 `docs/` 폴더로 추가하면 README에서 링크 가능
