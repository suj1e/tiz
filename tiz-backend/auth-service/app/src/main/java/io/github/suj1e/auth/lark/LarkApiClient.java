package io.github.suj1e.auth.lark;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * 飞书 API 客户端.
 * 用于调用飞书开放平台 API.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LarkApiClient {

    private static final String LARK_API_BASE_URL = "https://open.feishu.cn/open-apis";
    private static final String AUTH_ENDPOINT = "/authen/v1/oidc/access_token";
    private static final String USER_INFO_ENDPOINT = "/authen/v1/user_info";

    private final WebClient.Builder webClientBuilder;

    /**
     * 通过授权码获取用户访问令牌.
     */
    public LarkTokenResponse getAccessToken(String appId, String appSecret, String code) {
        WebClient webClient = webClientBuilder
            .baseUrl(LARK_API_BASE_URL)
            .build();

        TokenRequest request = new TokenRequest(appId, appSecret, "authorization_code");

        LarkApiEnvelope<LarkTokenResponse> envelope = webClient.post()
            .uri(AUTH_ENDPOINT)
            .header("Content-Type", "application/json")
            .bodyValue(request)
            .retrieve()
            .bodyToMono(LarkApiEnvelope.class)
            .block();

        if (envelope == null || envelope.code() != 0) {
            String msg = envelope != null ? envelope.msg() : "Unknown error";
            throw new LarkApiException("Lark API error: " + msg);
        }

        log.info("Obtained Lark access token for app: {}", appId);
        return envelope.data();
    }

    /**
     * 获取用户信息.
     */
    public LarkUserInfo getUserInfo(String accessToken) {
        WebClient webClient = webClientBuilder
            .baseUrl(LARK_API_BASE_URL)
            .build();

        LarkApiEnvelope<LarkUserInfoResponse> envelope = webClient.get()
            .uri(USER_INFO_ENDPOINT)
            .header("Authorization", "Bearer " + accessToken)
            .retrieve()
            .bodyToMono(LarkApiEnvelope.class)
            .block();

        if (envelope == null || envelope.code() != 0) {
            String msg = envelope != null ? envelope.msg() : "Unknown error";
            throw new LarkApiException("Lark API error: " + msg);
        }

        LarkUserInfoResponse data = envelope.data();
        log.info("Retrieved Lark user info: open_id={}", data.openId());
        return new LarkUserInfo(data.openId(), data.name(), data.email());
    }

    // Request/Response records

    public record TokenRequest(
        @JsonProperty("app_id") String appId,
        @JsonProperty("app_secret") String appSecret,
        @JsonProperty("grant_type") String grantType
    ) {}

    public record LarkApiEnvelope<T>(int code, String msg, T data) {}

    public record LarkTokenResponse(
        @JsonProperty("access_token") String accessToken,
        @JsonProperty("token_type") String tokenType,
        @JsonProperty("expires_in") int expiresIn,
        @JsonProperty("refresh_token") String refreshToken,
        @JsonProperty("refresh_expires_in") int refreshExpiresIn
    ) {}

    public record LarkUserInfoResponse(
        @JsonProperty("open_id") String openId,
        @JsonProperty("name") String name,
        @JsonProperty("email") String email,
        @JsonProperty("en_name") String enName,
        @JsonProperty("avatar_url") String avatarUrl,
        @JsonProperty("mobile") String mobile
    ) {}
}
