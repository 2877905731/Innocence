#include "../../windows/runner/assistant_crypto.h"
#include <cassert>
#include <iostream>
int main() {
  const std::vector<uint8_t> fixture{'f','i','x','t','u','r','e','-','o','n','l','y'};
  std::vector<uint8_t> ciphertext, plaintext, other;
  assert(AssistantProtectBytes(fixture, true, &ciphertext));
  assert(ciphertext != fixture);
  assert(AssistantProtectBytes(ciphertext, false, &plaintext));
  assert(plaintext == fixture);
  ciphertext[0] ^= 0xAA;
  assert(!AssistantProtectBytes(ciphertext, false, &other));
  assert(!AssistantProtectBytes({}, true, &other));
  std::cout << "PASS: DPAPI ciphertext, roundtrip, tamper rejection, empty rejection (4 checks)\n";
  SecureZeroMemory(plaintext.data(), plaintext.size());
}
