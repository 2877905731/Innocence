#ifndef INNOCENCE_ASSISTANT_VAULT_H_
#define INNOCENCE_ASSISTANT_VAULT_H_
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "assistant_crypto.h"
#include <memory>
#include <vector>

inline std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateAssistantVault(flutter::BinaryMessenger* messenger) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "innocence/assistant_vault", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler([](const auto& call, auto result) {
    const auto* bytes = call.arguments() == nullptr ? nullptr :
        std::get_if<std::vector<uint8_t>>(call.arguments());
    if (bytes == nullptr || bytes->empty() || bytes->size() > 65536) {
      result->Error("invalid_vault_input", "Invalid credential data."); return;
    }
    if (call.method_name() != "encrypt" && call.method_name() != "decrypt") { result->NotImplemented(); return; }
    std::vector<uint8_t> protected_bytes;
    if (!AssistantProtectBytes(*bytes, call.method_name() == "encrypt", &protected_bytes)) {
      result->Error("vault_failed", "Credential protection failed."); return;
    }
    result->Success(flutter::EncodableValue(protected_bytes));
    SecureZeroMemory(protected_bytes.data(), protected_bytes.size());
  });
  return channel;
}
#endif
