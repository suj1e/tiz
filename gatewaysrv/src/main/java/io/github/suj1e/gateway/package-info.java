/**
 * Tiz API Gateway Package.
 *
 * <p>This package contains the API Gateway implementation using Spring Cloud Gateway.</p>
 *
 * <h2>Features:</h2>
 * <ul>
 *   <li>Route configuration for all microservices</li>
 *   <li>JWT authentication filter</li>
 *   <li>CORS configuration</li>
 *   <li>Global exception handling</li>
 *   <li>Nacos service discovery integration</li>
 * </ul>
 *
 * <h2>Routes:</h2>
 * <ul>
 *   <li>/api/auth/v1/** - authsrv (8101)</li>
 *   <li>/api/chat/v1/** - chatsrv (8102)</li>
 *   <li>/api/content/v1/** - contentsrv (8103)</li>
 *   <li>/api/practice/v1/** - practicesrv (8104)</li>
 *   <li>/api/quiz/v1/** - quizsrv (8105)</li>
 *   <li>/api/user/v1/** - usersrv (8107)</li>
 * </ul>
 */
package io.github.suj1e.gateway;
