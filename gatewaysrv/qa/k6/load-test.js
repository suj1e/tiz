import http from 'k6/http';
import { check, sleep } from 'k6';

// 从环境变量获取配置
const BASE_URL = __ENV.TARGET_URL || 'http://localhost:40004';
const TOKEN = __ENV.TOKEN || '';

// 认证请求头
const authHeaders = {
  'Content-Type': 'application/json',
};

if (TOKEN) {
  authHeaders['Authorization'] = `Bearer ${TOKEN}`;
}

// 测试端点列表
const endpoints = [
  { path: '/actuator/health', method: 'GET', auth: false, name: '健康检查' },
  { path: '/api/v1/auth/login', method: 'POST', auth: false, name: '登录', body: '{"username":"test","password":"test"}' },
  { path: '/api/v1/seqra/meals', method: 'GET', auth: true, name: '膳食列表' },
  { path: '/api/v1/seqra/recommend', method: 'GET', auth: true, name: '推荐服务' },
  { path: '/api/v1/mix/data', method: 'GET', auth: true, name: 'Mix数据' },
];

// 随机选择端点
function getRandomEndpoint() {
  return endpoints[Math.floor(Math.random() * endpoints.length)];
}

// 构建请求
function buildRequest(endpoint) {
  const url = `${BASE_URL}${endpoint.path}`;
  const params = {
    headers: { ...authHeaders },
    tags: { name: endpoint.name },
  };

  if (endpoint.method === 'POST' && endpoint.body) {
    return {
      method: endpoint.method,
      url: url,
      params: params,
      body: endpoint.body,
    };
  }

  return {
    method: endpoint.method,
    url: url,
    params: params,
  };
}

// 默认函数 - 每个 VU 都会执行
export default function () {
  const endpoint = getRandomEndpoint();

  // 跳过需要认证但没有 token 的请求
  if (endpoint.auth && !TOKEN) {
    return;
  }

  const req = buildRequest(endpoint);
  const res = http.request(req.method, req.url, req.body || null, req.params);

  // 验证响应
  const checks = {
    [`${endpoint.name}: 状态码合格`]: (r) => r.status < 500,
    [`${endpoint.name}: 响应时间 < 500ms`]: (r) => r.timings.duration < 500,
    [`${endpoint.name}: 响应时间 < 1s`]: (r) => r.timings.duration < 1000,
  };

  // 特定端点的额外检查
  if (endpoint.path === '/actuator/health') {
    checks[`${endpoint.name}: 服务健康`] = (r) => r.status === 200 && r.json('status') === 'UP';
  }

  check(res, checks);

  // 随机思考时间 1-3 秒
  sleep(Math.random() * 2 + 1);
}

// Setup 函数 - 测试开始前执行
export function setup() {
  console.log(`开始压测: ${BASE_URL}`);
  console.log(`认证: ${TOKEN ? '已启用' : '未启用'}`);

  // 健康检查
  const res = http.get(`${BASE_URL}/actuator/health`);
  if (res.status !== 200) {
    throw new Error(`目标服务不可用: ${BASE_URL}`);
  }

  console.log(`目标服务状态: ${res.json('status')}`);

  // 如果需要认证但没有 token，尝试获取
  if (!TOKEN) {
    console.log('未提供 TOKEN，仅测试公开端点');
  }

  return { startTime: new Date().toISOString() };
}

// Teardown 函数 - 测试结束后执行
export function teardown(data) {
  console.log(`压测完成: ${data.startTime}`);
}
