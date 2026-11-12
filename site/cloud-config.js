/**
 * Orbit · 云服务公开配置
 * 这些值由 workbuddy_cloud_service 激活成功后返回的 publicConfig 写入，
 * 是允许放进前端代码的公开值（publishableKey 本身不带权限，服务端会校验 Origin）。
 * 不要在前端放置任何长期密钥 / client_secret / 服务端凭证。
 */
window.__ORBIT_CLOUD__ = {
  // 本仓库自己的云服务环境（appId: wbapp_cbPJ6Q5BxSWyE86of3cWwG）
  // 注意：endpoint 必须与发布域名完全一致，服务端会做严格 Origin 匹配。
  endpoint: 'https://orbit-github-nav-58684.app.workbuddy.host',
  oauthRelayBaseUrl: 'https://www.workbuddy.cn/v2/as/genie-baas/oauth',
  publishableKey: 'wbpk_cbPJ6Q5BxSWyE86of3cWwG_roHnSM2HKfAlOD4Q9oU1QERZXyMckabi',

  /**
   * GitHub 账号连接（可选）。
   * 浏览器里无法安全保存 OAuth App 的 client_secret，所以授权码交换由你自己的
   * 免费 Cloudflare Worker 完成：把 proxy/github-oauth-worker.js 部署好，
   * 在 Worker 环境变量里填 GITHUB_CLIENT_ID / GITHUB_CLIENT_SECRET，
   * 再把下面的 clientId 与 proxyUrl 填上即可启用「使用 GitHub 账号连接」。
   * 不配置也不影响使用：仍可用个人访问令牌方式，或完全不连接。
   */
  githubOAuth: {
    clientId: '',
    proxyUrl: '',
  },
};
