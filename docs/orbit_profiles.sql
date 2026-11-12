-- Orbit · 云数据库建表脚本（orbit_profiles）
-- 应用：Orbit导航站（appId: wbapp_cbPJ6Q5BxSWyE86of3cWwG）
-- 用途：邮箱 / 手机验证码登录后，收藏、设置、GitHub 连接信息的按用户隔离存储。
-- 说明：语句按顺序逐条执行（多数面板一次只接受一条语句）。
--      第 2 段起是 RLS 授权，没有它们前端会收到 42501。

-- ── 1. 建表 ────────────────────────────────────────────────
CREATE TABLE orbit_profiles (
  id            BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  owner_id      TEXT        NOT NULL DEFAULT auth.uid(),
  owner_name    TEXT,
  favorites     JSONB       NOT NULL DEFAULT '[]'::jsonb,
  settings      JSONB       NOT NULL DEFAULT '{}'::jsonb,
  github_login  TEXT,
  github_avatar TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT orbit_profiles_owner_id_key UNIQUE (owner_id)
);

COMMENT ON TABLE orbit_profiles IS 'Orbit 导航站用户数据：收藏、设置、GitHub 连接信息（按 owner_id 隔离）';

-- ── 2. 表授权（两个门禁之一：能不能碰这张表）──────────────
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.orbit_profiles TO authenticated, anon;

-- ── 3. 开启 RLS ───────────────────────────────────────────
ALTER TABLE orbit_profiles ENABLE ROW LEVEL SECURITY;

-- ── 4. 四条 RLS 策略（两个门禁之二：能碰哪些行）──────────
DROP POLICY IF EXISTS orbit_profiles_select_own ON orbit_profiles;
CREATE POLICY orbit_profiles_select_own ON orbit_profiles
  FOR SELECT TO authenticated, anon
  USING (owner_id = auth.uid());

DROP POLICY IF EXISTS orbit_profiles_insert_own ON orbit_profiles;
CREATE POLICY orbit_profiles_insert_own ON orbit_profiles
  FOR INSERT TO authenticated, anon
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS orbit_profiles_update_own ON orbit_profiles;
CREATE POLICY orbit_profiles_update_own ON orbit_profiles
  FOR UPDATE TO authenticated, anon
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS orbit_profiles_delete_own ON orbit_profiles;
CREATE POLICY orbit_profiles_delete_own ON orbit_profiles
  FOR DELETE TO authenticated, anon
  USING (owner_id = auth.uid());

-- ── 5. 便利触发器：写入时自动刷新 updated_at（可选）──────
CREATE OR REPLACE FUNCTION orbit_profiles_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS orbit_profiles_touch_trg ON orbit_profiles;
CREATE TRIGGER orbit_profiles_touch_trg
  BEFORE UPDATE ON orbit_profiles
  FOR EACH ROW EXECUTE FUNCTION orbit_profiles_touch();
