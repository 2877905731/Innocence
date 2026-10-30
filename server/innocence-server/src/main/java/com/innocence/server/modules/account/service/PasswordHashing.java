package com.innocence.server.modules.account.service;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;
import java.util.HexFormat;

/** Versioned password hashes; old salted SHA-256 is verified only for migration. */
final class PasswordHashing {
    private static final String PREFIX = "pbkdf2-sha256$";
    private static final int ITERATIONS = 600_000;
    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordHashing() { }

    static String encode(String password) {
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        byte[] hash = derive(password, salt, ITERATIONS);
        return PREFIX + ITERATIONS + "$" + Base64.getEncoder().encodeToString(salt)
                + "$" + Base64.getEncoder().encodeToString(hash);
    }

    static boolean matches(String password, String encoded, String legacySalt) {
        if (password == null || encoded == null) return false;
        if (!encoded.startsWith(PREFIX)) {
            if (!encoded.matches("[0-9a-f]{64}") || legacySalt == null) return false;
            try {
                byte[] expected = HexFormat.of().parseHex(encoded);
                byte[] actual = MessageDigest.getInstance("SHA-256")
                        .digest((password + legacySalt).getBytes(StandardCharsets.UTF_8));
                return MessageDigest.isEqual(expected, actual);
            } catch (GeneralSecurityException exception) {
                throw new IllegalStateException("Password hashing unavailable", exception);
            }
        }
        try {
            String[] fields = encoded.split("\\$", -1);
            if (fields.length != 4) return false;
            int iterations = Integer.parseInt(fields[1]);
            if (iterations < 100_000 || iterations > 1_200_000) return false;
            byte[] salt = Base64.getDecoder().decode(fields[2]);
            byte[] expected = Base64.getDecoder().decode(fields[3]);
            if (salt.length != 16 || expected.length != 32) return false;
            return MessageDigest.isEqual(expected, derive(password, salt, iterations));
        } catch (IllegalArgumentException exception) {
            return false;
        }
    }

    static boolean needsUpgrade(String encoded) {
        return encoded == null || !encoded.startsWith(PREFIX + ITERATIONS + "$");
    }

    private static byte[] derive(String password, byte[] salt, int iterations) {
        char[] characters = password.toCharArray();
        PBEKeySpec spec = new PBEKeySpec(characters, salt, iterations, 256);
        Arrays.fill(characters, '\0');
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException("Password hashing unavailable", exception);
        } finally {
            spec.clearPassword();
        }
    }
}
