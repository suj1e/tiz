import http from 'k6/http';
import { check, sleep } from 'k6';

// 从环境变量获取配置
const BASE_URL = __ENV.BASE_URL || 'http://localhost:40006';
const CONTEXT_PATH = __ENV.CONTEXT_PATH || 'auth';
const TEST_USERNAME = __ENV.TEST_USERNAME || 'admin';
const TEST_PASSWORD = __ENV.TEST_PASSWORD || 'admin123';
const TOKEN = __ENV.TOKEN || '';

// 构建完整 URL
const getBaseUrl = () => `${BASE_URL}/${CONTEXT_PATH}`;

// 认证请求头
const getHeaders = (includeAuth = false) => {
  const headers = {
    'Content-Type': 'application/json',
  };

  if (includeAuth && TOKEN) {
    headers['Authorization'] = `Bearer ${TOKEN}`;
  }

  return headers;
};

// 测试端点列表
const endpoints = [
  { path: '/actuator/health', method: 'GET', auth: false, name: '健康检查' },
  { path: '/v1/register', method: 'POST', auth: false, name: '用户注册', bodyGenerator: () => {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    return JSON.stringify({
      username: `test_user_${timestamp}_${random}`,
      email: `test_user_${timestamp}_${random}@example.com`,
      password: 'Test@123456',
    });
  }},
  { path: '/v1/login', method: 'POST', auth: false, name: '用户登录', body: JSON.stringify({
    username: TEST_USERNAME,
    password: TEST_PASSWORD,
  })},
  { path: '/v1/refresh', method: 'POST', auth: false, name: '刷新令牌' },
  { path: '/v1/users/me', method: 'GET', auth: true, name: '获取用户信息' },
  { path: '/v1/roles', method: 'GET', auth: true, name: '获取角色列表' },
];

// 随机选择端点
function getRandomEndpoint() {
  return endpoints[Math.floor(Math.random() * endpoints.length)];
}

// 构建请求
function buildRequest(endpoint) {
  const url = `${getBaseUrl()}${endpoint.path}`;
  const params = {
    headers: getHeaders(endpoint.auth),
    tags: { name: endpoint.name },
  };

  const body = endpoint.bodyGenerator ? endpoint.bodyGenerator() : endpoint.body;

  if (endpoint.method === 'POST' && body) {
    return {
      method: endpoint.method,
      url: url,
      params: params,
      body: body,
    };
  }

  return {
    method: endpoint.method,
    url: url,
    params: params,
  };
}

// 存储登录 token
let authToken = null;

// 默认函数 - 每个 VU 都会执行
export default function () {
  const endpoint = getRandomEndpoint();

  // 跳过需要认证但没有 token 的请求（尝试登录获取 token）
  if (endpoint.auth && !authToken && !TOKEN) {
    // 尝试登录
    const loginUrl = `${getBaseUrl()}/v1/login`;
    const loginRes = http.post(loginUrl, JSON.stringify({
      username: TEST_USERNAME,
      password: TEST_PASSWORD,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });

    if (loginRes.status === 200 && loginRes.json('accessToken')) {
      authToken = loginRes.json('accessToken');
    } else {
      // 登录失败，跳过需要认证的请求
      return;
    }
  }

  const req = buildRequest(endpoint);
  const res = http.request(req.method, req.url, req.body || null, req.params);

  // 验证响应
  const checks = {
    [`${endpoint.name}: 状态码 < 500`]: (r) => r.status < 500,
    [`${endpoint.name}: 响应时间 < 200ms`]: (r) => r.timings.duration < 200,
    [`${endpoint.name}: 响应时间 < 500ms`]: (r) => r.timings.duration < 500,
  };

  // 特定端点的额外检查
  if (endpoint.path === '/actuator/health') {
    try {
      checks[`${endpoint.name}: 服务健康`] = (r) => r.status === 200 && r.json('status') === 'UP';
    } catch (e) {
      checks[`${endpoint.name}: 服务健康`] = (r) => r.status === 200;
    }
  }

  if (endpoint.path === '/v1/login') {
    checks[`${endpoint.name}: 登录成功或有 token`] = (r) => r.status === 200 && r.json('accessToken') !== undefined;
  }

  if (endpoint.path === '/v1/users/me') {
    checks[`${endpoint.name}: 获取用户成功`] = (r) => r.status === 200;
  }

  check(res, checks);

  // 随机思考时间 1-3 秒
  sleep(Math.random() * 2 + 1);
}

// Setup 函数 - 测试开始前执行
export function setup() {
  console.log(`==========================================`);
  console.log(`开始压测: ${getBaseUrl()}`);
  console.log(`测试账号: ${TEST_USERNAME}`);
  console.log(`认证: ${TOKEN || authToken ? '已启用' : '将自动登录'}`);
  console.log(`==========================================`);

  // 健康检查
  const healthUrl = `${getBaseUrl()}/actuator/health`;
  const res = http.get(healthUrl);

  if (res.status !== 200) {
    throw new Error(`目标服务不可用: ${getBaseUrl()}`);
  }

  try {
    const healthStatus = res.json('status');
    console.log(`目标服务状态: ${healthStatus}`);
  } catch (e) {
    console.log(`目标服务状态: ${res.status}`);
  }

  return {
    startTime: new Date().toISOString(),
    baseUrl: getBaseUrl(),
    testUsername: TEST_USERNAME,
  };
}

// Teardown 函数 - 测试结束后执行
export function teardown(data) {
  console.log(`==========================================`);
  console.log(`压测完成: ${data.startTime}`);
  console.log(`目标: ${data.baseUrl}`);
  console.log(`==========================================`);
}

// 选项配置（可以通过 --stage 覆盖）
export const options = {
  // 阈值配置
  thresholds: {
    // 95% 请求响应时间 < 500ms
    http_req_duration: ['p(95)<500'],
    // 错误率 < 5%
    http_req_failed: ['rate<0.05'],
    // 登录请求成功率 > 95%
    'http_req_duration{endpoint:用户登录}': ['p(95)<200'],
  },
};
