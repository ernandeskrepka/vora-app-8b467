-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "UserRole" AS ENUM ('ADMIN', 'EDITOR');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "PostStatus" AS ENUM ('RASCUNHO', 'AGUARDANDO_APROVACAO', 'APROVADO', 'PUBLICANDO', 'PUBLICADO', 'REPROVADO', 'POST_SEM_RESPOSTA', 'FALHOU', 'CANCELADO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "PostFormat" AS ENUM ('IMAGEM_UNICA', 'CARROSSEL', 'VIDEO', 'REELS');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "Network" AS ENUM ('INSTAGRAM', 'FACEBOOK');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "MediaKind" AS ENUM ('IMAGEM', 'VIDEO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "MetaAssetType" AS ENUM ('INSTAGRAM', 'FACEBOOK_PAGE', 'AD_ACCOUNT');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "MetaAuthMode" AS ENUM ('SYSTEM_USER', 'OAUTH');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "MetaConnectionStatus" AS ENUM ('CONECTADO', 'EXPIRADO', 'SEM_PERMISSAO', 'REVOGADO', 'NAO_CONFIGURADO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "ApprovalRequestStatus" AS ENUM ('PENDENTE', 'DECIDIDO', 'EXPIRADO', 'SUBSTITUIDO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "ApprovalDecisionType" AS ENUM ('APROVADO', 'REPROVADO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "PublishAttemptStatus" AS ENUM ('SUCESSO', 'ERRO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "NotificationChannel" AS ENUM ('WHATSAPP', 'SLACK', 'EMAIL', 'LOG');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "NotificationStatus" AS ENUM ('NA_FILA', 'ENVIADO', 'ENTREGUE', 'LIDO', 'FALHOU');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "PlanningStatus" AS ENUM ('IDEIA', 'EM_PRODUCAO', 'PRONTO', 'VIROU_POST', 'ARQUIVADO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "AssetKind" AS ENUM ('IMAGEM', 'VIDEO', 'DOCUMENTO');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateEnum
DO $$
BEGIN
    CREATE TYPE "ActorType" AS ENUM ('USUARIO', 'CLIENTE', 'SISTEMA');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END;
$$;

-- CreateTable
CREATE TABLE IF NOT EXISTS "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'EDITOR',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "Session" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "Client" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "timezone" TEXT NOT NULL DEFAULT 'America/Sao_Paulo',
    "notes" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ClientContact" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phoneE164" TEXT NOT NULL,
    "isApprover" BOOLEAN NOT NULL DEFAULT true,
    "receivesReminders" BOOLEAN NOT NULL DEFAULT true,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ClientContact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "MetaConnection" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "assetType" "MetaAssetType" NOT NULL,
    "assetId" TEXT NOT NULL,
    "assetName" TEXT,
    "authMode" "MetaAuthMode" NOT NULL DEFAULT 'SYSTEM_USER',
    "tokenCiphertext" TEXT,
    "tokenExpiresAt" TIMESTAMP(3),
    "scopes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "status" "MetaConnectionStatus" NOT NULL DEFAULT 'NAO_CONFIGURADO',
    "lastCheckedAt" TIMESTAMP(3),
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MetaConnection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "PlanningItem" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "notes" TEXT,
    "targetDate" TIMESTAMP(3),
    "status" "PlanningStatus" NOT NULL DEFAULT 'IDEIA',
    "postId" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlanningItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ClientAsset" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "kind" "AssetKind" NOT NULL,
    "storageKey" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "width" INTEGER,
    "height" INTEGER,
    "durationSeconds" DOUBLE PRECISION,
    "originalFilename" TEXT,
    "label" TEXT,
    "uploadedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ClientAsset_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "Post" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "createdById" TEXT,
    "caption" TEXT NOT NULL DEFAULT '',
    "format" "PostFormat" NOT NULL,
    "networks" "Network"[] DEFAULT ARRAY[]::"Network"[],
    "scheduledAt" TIMESTAMP(3) NOT NULL,
    "status" "PostStatus" NOT NULL DEFAULT 'RASCUNHO',
    "version" INTEGER NOT NULL DEFAULT 1,
    "approvedAt" TIMESTAMP(3),
    "publishedAt" TIMESTAMP(3),
    "canceledAt" TIMESTAMP(3),
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Post_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "PostMedia" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "kind" "MediaKind" NOT NULL,
    "storageKey" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "width" INTEGER,
    "height" INTEGER,
    "sizeBytes" INTEGER NOT NULL,
    "durationSeconds" DOUBLE PRECISION,
    "originalFilename" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PostMedia_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ApprovalRequest" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "postVersion" INTEGER NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "status" "ApprovalRequestStatus" NOT NULL DEFAULT 'PENDENTE',
    "channel" "NotificationChannel" NOT NULL DEFAULT 'WHATSAPP',
    "sentAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "decidedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ApprovalRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ApprovalDecision" (
    "id" TEXT NOT NULL,
    "approvalRequestId" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "postVersion" INTEGER NOT NULL,
    "decision" "ApprovalDecisionType" NOT NULL,
    "approverName" TEXT NOT NULL,
    "comment" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "decidedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ApprovalDecision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "PublishAttempt" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "network" "Network" NOT NULL,
    "attempt" INTEGER NOT NULL,
    "status" "PublishAttemptStatus" NOT NULL,
    "dryRun" BOOLEAN NOT NULL DEFAULT false,
    "externalId" TEXT,
    "permalink" TEXT,
    "errorCode" TEXT,
    "errorMessage" TEXT,
    "requestSummary" TEXT,
    "responseBody" JSONB,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),

    CONSTRAINT "PublishAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "PostPublication" (
    "id" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "network" "Network" NOT NULL,
    "externalId" TEXT NOT NULL,
    "permalink" TEXT,
    "dryRun" BOOLEAN NOT NULL DEFAULT false,
    "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PostPublication_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "Notification" (
    "id" TEXT NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "destination" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "status" "NotificationStatus" NOT NULL DEFAULT 'NA_FILA',
    "payload" JSONB,
    "providerMessageId" TEXT,
    "errorMessage" TEXT,
    "postId" TEXT,
    "clientId" TEXT,
    "contactId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "AdInsightDaily" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "adAccountId" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "campaignId" TEXT NOT NULL,
    "campaignName" TEXT,
    "spend" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "reach" INTEGER NOT NULL DEFAULT 0,
    "impressions" INTEGER NOT NULL DEFAULT 0,
    "clicks" INTEGER NOT NULL DEFAULT 0,
    "ctr" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "cpc" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "cpm" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "conversions" INTEGER NOT NULL DEFAULT 0,
    "costPerResult" DECIMAL(14,4),
    "currency" TEXT NOT NULL DEFAULT 'BRL',
    "raw" JSONB,
    "collectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdInsightDaily_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "AuditLog" (
    "id" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "actorType" "ActorType" NOT NULL,
    "actorUserId" TEXT,
    "actorName" TEXT,
    "fromStatus" TEXT,
    "toStatus" TEXT,
    "metadata" JSONB,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "Setting" (
    "key" TEXT NOT NULL,
    "value" JSONB NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Setting_pkey" PRIMARY KEY ("key")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "Session_tokenHash_key" ON "Session"("tokenHash");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "Client_slug_key" ON "Client"("slug");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ClientContact_clientId_idx" ON "ClientContact"("clientId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "ClientContact_clientId_phoneE164_key" ON "ClientContact"("clientId", "phoneE164");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "MetaConnection_status_idx" ON "MetaConnection"("status");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "MetaConnection_clientId_assetType_key" ON "MetaConnection"("clientId", "assetType");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "PlanningItem_postId_key" ON "PlanningItem"("postId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "PlanningItem_clientId_status_idx" ON "PlanningItem"("clientId", "status");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ClientAsset_clientId_createdAt_idx" ON "ClientAsset"("clientId", "createdAt");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Post_clientId_scheduledAt_idx" ON "Post"("clientId", "scheduledAt");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Post_status_scheduledAt_idx" ON "Post"("status", "scheduledAt");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "PostMedia_postId_idx" ON "PostMedia"("postId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "PostMedia_postId_position_key" ON "PostMedia"("postId", "position");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "ApprovalRequest_tokenHash_key" ON "ApprovalRequest"("tokenHash");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ApprovalRequest_postId_postVersion_idx" ON "ApprovalRequest"("postId", "postVersion");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ApprovalRequest_status_idx" ON "ApprovalRequest"("status");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "ApprovalDecision_approvalRequestId_key" ON "ApprovalDecision"("approvalRequestId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ApprovalDecision_postId_idx" ON "ApprovalDecision"("postId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "PublishAttempt_postId_idx" ON "PublishAttempt"("postId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "PublishAttempt_postId_network_attempt_key" ON "PublishAttempt"("postId", "network", "attempt");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "PostPublication_postId_network_key" ON "PostPublication"("postId", "network");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Notification_postId_idx" ON "Notification"("postId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Notification_providerMessageId_idx" ON "Notification"("providerMessageId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "AdInsightDaily_clientId_date_idx" ON "AdInsightDaily"("clientId", "date");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "AdInsightDaily_clientId_campaignId_date_key" ON "AdInsightDaily"("clientId", "campaignId", "date");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "AuditLog_entityType_entityId_createdAt_idx" ON "AuditLog"("entityType", "entityId", "createdAt");

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'Session_userId_fkey'
          AND conrelid = '"Session"'::regclass
    ) THEN
        ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ClientContact_clientId_fkey'
          AND conrelid = '"ClientContact"'::regclass
    ) THEN
        ALTER TABLE "ClientContact" ADD CONSTRAINT "ClientContact_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'MetaConnection_clientId_fkey'
          AND conrelid = '"MetaConnection"'::regclass
    ) THEN
        ALTER TABLE "MetaConnection" ADD CONSTRAINT "MetaConnection_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'PlanningItem_clientId_fkey'
          AND conrelid = '"PlanningItem"'::regclass
    ) THEN
        ALTER TABLE "PlanningItem" ADD CONSTRAINT "PlanningItem_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'PlanningItem_postId_fkey'
          AND conrelid = '"PlanningItem"'::regclass
    ) THEN
        ALTER TABLE "PlanningItem" ADD CONSTRAINT "PlanningItem_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ClientAsset_clientId_fkey'
          AND conrelid = '"ClientAsset"'::regclass
    ) THEN
        ALTER TABLE "ClientAsset" ADD CONSTRAINT "ClientAsset_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'Post_clientId_fkey'
          AND conrelid = '"Post"'::regclass
    ) THEN
        ALTER TABLE "Post" ADD CONSTRAINT "Post_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'Post_createdById_fkey'
          AND conrelid = '"Post"'::regclass
    ) THEN
        ALTER TABLE "Post" ADD CONSTRAINT "Post_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'PostMedia_postId_fkey'
          AND conrelid = '"PostMedia"'::regclass
    ) THEN
        ALTER TABLE "PostMedia" ADD CONSTRAINT "PostMedia_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ApprovalRequest_postId_fkey'
          AND conrelid = '"ApprovalRequest"'::regclass
    ) THEN
        ALTER TABLE "ApprovalRequest" ADD CONSTRAINT "ApprovalRequest_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ApprovalDecision_approvalRequestId_fkey'
          AND conrelid = '"ApprovalDecision"'::regclass
    ) THEN
        ALTER TABLE "ApprovalDecision" ADD CONSTRAINT "ApprovalDecision_approvalRequestId_fkey" FOREIGN KEY ("approvalRequestId") REFERENCES "ApprovalRequest"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ApprovalDecision_postId_fkey'
          AND conrelid = '"ApprovalDecision"'::regclass
    ) THEN
        ALTER TABLE "ApprovalDecision" ADD CONSTRAINT "ApprovalDecision_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'PublishAttempt_postId_fkey'
          AND conrelid = '"PublishAttempt"'::regclass
    ) THEN
        ALTER TABLE "PublishAttempt" ADD CONSTRAINT "PublishAttempt_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'PostPublication_postId_fkey'
          AND conrelid = '"PostPublication"'::regclass
    ) THEN
        ALTER TABLE "PostPublication" ADD CONSTRAINT "PostPublication_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'Notification_postId_fkey'
          AND conrelid = '"Notification"'::regclass
    ) THEN
        ALTER TABLE "Notification" ADD CONSTRAINT "Notification_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
END;
$$;

-- AddForeignKey
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'AdInsightDaily_clientId_fkey'
          AND conrelid = '"AdInsightDaily"'::regclass
    ) THEN
        ALTER TABLE "AdInsightDaily" ADD CONSTRAINT "AdInsightDaily_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END;
$$;
