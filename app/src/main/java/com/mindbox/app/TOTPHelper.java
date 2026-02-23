package com.mindbox.app;

import android.net.Uri;
import java.util.Locale;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.apache.commons.codec.binary.Base32;

public class TOTPHelper {

    public static String generateCode(String secretKey) {
        if (secretKey == null || secretKey.trim().isEmpty()) return "000000";
        try {
            String cleanKey = secretKey.replace(" ", "").toUpperCase().trim();
            long timeIndex = (System.currentTimeMillis() / 1000 / 30);

            Base32 base32 = new Base32();
            byte[] bytes = base32.decode(cleanKey);

            byte[] counter = new byte[8];
            long temp = timeIndex;
            for (int i = 7; i >= 0; i--) {
                counter[i] = (byte) (temp & 0xFF);
                temp >>= 8;
            }

            SecretKeySpec keySpec = new SecretKeySpec(bytes, "HmacSHA1");
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(keySpec);
            byte[] hash = mac.doFinal(counter);

            int offset = hash[hash.length - 1] & 0x0F;
            int binary = ((hash[offset] & 0x7F) << 24) |
                         ((hash[offset + 1] & 0xFF) << 16) |
                         ((hash[offset + 2] & 0xFF) << 8) |
                         (hash[offset + 3] & 0xFF);

            int otp = binary % (int) Math.pow(10, 6);
            return String.format(Locale.US, "%06d", otp);
        } catch (Exception e) {
            e.printStackTrace();
            return "000000";
        }
    }

    /**
     * Calcula los segundos restantes del ciclo actual (30 a 0)
     * ESTO ES LO QUE EL ADAPTADOR NECESITA PARA COMPILAR
     */
    public static int getSecondsLeft() {
        long nowSeconds = System.currentTimeMillis() / 1000;
        return (int) (30 - (nowSeconds % 30));
    }

    public static int getProgress() {
        return (int) (100 - ((System.currentTimeMillis() / 1000) % 30) * 3.33);
    }

    public static String[] parseQrCode(String content) {
        try {
            Uri uri = Uri.parse(content);
            if (!"otpauth".equals(uri.getScheme())) return null;

            String secret = uri.getQueryParameter("secret");
            if (secret == null) return null;

            String issuer = uri.getQueryParameter("issuer");
            if (issuer == null) {
                String path = uri.getPath();
                if (path != null) {
                    issuer = path.replace("/", "").split(":")[0];
                } else {
                    issuer = "Servicio Desconocido";
                }
            }

            String account = "";
            String path = uri.getPath();
            if (path != null && path.contains(":")) {
                account = path.split(":")[1];
            }

            return new String[]{issuer, account, secret};
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}