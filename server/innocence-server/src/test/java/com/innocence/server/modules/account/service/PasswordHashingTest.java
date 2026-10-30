package com.innocence.server.modules.account.service;

import org.junit.jupiter.api.Test;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;
import static org.junit.jupiter.api.Assertions.*;

class PasswordHashingTest {
    @Test void currentHashSupportsUnicodeAndRejectsWrongPassword() {
        String password = "synthetic-密码-123";
        String encoded = PasswordHashing.encode(password);
        assertTrue(PasswordHashing.matches(password, encoded, "unused"));
        assertFalse(PasswordHashing.matches(password + "x", encoded, "unused"));
        assertFalse(PasswordHashing.needsUpgrade(encoded));
        assertNotEquals(encoded, PasswordHashing.encode(password));
    }

    @Test void legacyCredentialsRemainUsableAndRequireUpgrade() throws Exception {
        String legacy = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                .digest("synthetic-passwordsalt".getBytes(StandardCharsets.UTF_8)));
        assertTrue(PasswordHashing.matches("synthetic-password", legacy, "salt"));
        assertFalse(PasswordHashing.matches("incorrect", legacy, "salt"));
        assertTrue(PasswordHashing.needsUpgrade(legacy));
    }

    @Test void malformedHashesAndExcessiveWorkFactorsAreRejected() {
        assertFalse(PasswordHashing.matches("password", null, "salt"));
        assertFalse(PasswordHashing.matches(null, "hash", "salt"));
        assertFalse(PasswordHashing.matches("password", "pbkdf2-sha256$999999999$AA==$AA==", "salt"));
        assertFalse(PasswordHashing.matches("password", "pbkdf2-sha256$600000$invalid$invalid", "salt"));
        assertFalse(PasswordHashing.matches("password", "pbkdf2-sha256$bad", "salt"));
    }
}
