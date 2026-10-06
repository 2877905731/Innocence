#ifndef INNOCENCE_ASSISTANT_CRYPTO_H_
#define INNOCENCE_ASSISTANT_CRYPTO_H_
#include <windows.h>
#include <dpapi.h>
#include <vector>
#include <cstdint>
inline bool AssistantProtectBytes(const std::vector<uint8_t>& input_bytes,
                                  bool encrypt, std::vector<uint8_t>* result) {
  if (input_bytes.empty() || input_bytes.size() > 65536 || result == nullptr) return false;
  DATA_BLOB input{static_cast<DWORD>(input_bytes.size()), const_cast<BYTE*>(input_bytes.data())};
  DATA_BLOB output{};
  const BOOL ok = encrypt ? CryptProtectData(&input, nullptr, nullptr, nullptr, nullptr,
          CRYPTPROTECT_UI_FORBIDDEN, &output) :
      CryptUnprotectData(&input, nullptr, nullptr, nullptr, nullptr, CRYPTPROTECT_UI_FORBIDDEN, &output);
  if (!ok) return false;
  result->assign(output.pbData, output.pbData + output.cbData);
  SecureZeroMemory(output.pbData, output.cbData); LocalFree(output.pbData);
  return true;
}
#endif
