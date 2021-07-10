package nju.czh;

import com.eatthepath.pushy.apns.ApnsClient;
import com.eatthepath.pushy.apns.ApnsClientBuilder;

import java.io.File;
import java.io.IOException;

public class NotificationPusher {
    final ApnsClient apnsClient = new ApnsClientBuilder()
            .setApnsServer("gateway.sandbox.push.apple.com", 2195)
            .setClientCredentials(new File("/Users/cui/Documents/UDO-Certificate/udo-apns.p12"), "123456")
            .build();

    public NotificationPusher() throws IOException {
    }

    public void pushNotification() {
        
    }
}
