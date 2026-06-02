# Ortak Hesap - Backend Kurulum Kılavuzu

## Gereksinimler
- Node.js 18+
- PostgreSQL 15+
- npm veya yarn

## Kurulum Adımları

### 1. Bağımlılıkları yükle
```bash
cd backend
npm install
```

### 2. Ortam değişkenlerini ayarla
`.env` dosyası oluştur:
```env
DATABASE_URL="postgresql://kullanici:sifre@localhost:5432/ortakhesap?schema=public"
PORT=3000
```

### 3. Veritabanını oluştur
```bash
# PostgreSQL'de veritabanı oluştur
createdb ortakhesap

# Prisma migration'ları çalıştır
npm run prisma:migrate

# Prisma Client oluştur
npm run prisma:generate
```

### 4. Uygulamayı başlat
```bash
npm run start:dev
```

API `http://localhost:3000/api` adresinde çalışacak.

### 5. Prisma Studio (Opsiyonel)
Veritabanını görsel olarak yönetmek için:
```bash
npm run prisma:studio
```

## API Endpoint'leri

| Yöntem | URL | Açıklama |
|--------|-----|----------|
| GET | `/api/groups/user/:userId` | Kullanıcının grupları |
| GET | `/api/groups/:id` | Grup detayı |
| POST | `/api/groups` | Yeni grup oluştur |
| POST | `/api/expenses` | Harcama ekle |
| GET | `/api/expenses/group/:groupId` | Gruptaki harcamalar |
| GET | `/api/debts/group/:groupId/summary` | Borç analizi (Min. Cash Flow) |
| POST | `/api/payments` | Ödeme başlat |
| PATCH | `/api/payments/:id/confirm` | Ödeme onayla |
| PATCH | `/api/payments/:id/reject` | Ödeme reddet |
