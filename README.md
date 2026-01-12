# 🎬 Movie & TV Discovery App

Flutter ile geliştirilmiş, kullanıcıların film ve dizileri keşfedebildiği, **kişisel listeler oluşturabildiği**, favorilerine ekleyebildiği ve izlediklerini takip edebildiği modern bir mobil uygulama.

Bu proje; **API kullanımı**, **authentication**, **state management**, **local & remote data yönetimi** ve **ölçeklenebilir mimari** konularını öğrenmek ve uygulamak amacıyla geliştirilmiştir.

---

## 🚀 Temel Özellikler

### 🔍 Keşif & Arama

- Popüler filmler ve diziler
- Günlük / haftalık trend içerikler
- Film & dizi arama
- Detay sayfası:
  - Poster
  - Açıklama
  - Türler
  - Yayın tarihi
  - Puan
    ...

---

### 👤 Kullanıcı Sistemi

- Kullanıcı girişi (Authentication)
- Kullanıcıya özel veri yönetimi
- Oturum bazlı içerik gösterimi

---

### ⭐ Favoriler

- Film & dizileri favorilere ekleme
- Favoriler ekranında listeleme
- Favorilerin kullanıcıya özel saklanması

---

### 📺 İzlenenler

- Daha önce izlenen film/dizileri işaretleme
- İzlenenler için **ayrı bir ekran**
- Kullanıcının izleme geçmişini takip edebilmesi

---

### 📂 Kişisel Listeler

- Kullanıcının kendi film/dizi listelerini oluşturabilmesi
- Listeye içerik ekleme / çıkarma
- Örnek listeler:
  - İzlenecekler
  - Tekrar izlenecekler
  - Favori diziler
  - Özel temalı listeler

---

## 🛠️ Kullanılan Teknolojiler

- **Flutter**
- **Dart**
- **RESTful API**
- **HTTP**
- **State Management** (Provider / Riverpod / Bloc)
- **Authentication** (Firebase Auth / benzeri)
- **Local Storage**
- **Material Design**

---

## 🌐 Kullanılan API

- **The Movie Database (TMDB) API**

> ⚠️ API anahtarı güvenlik nedeniyle repoya eklenmemiştir.

---

## 🧠 Mimari Yaklaşım

- Clean Architecture prensiplerine uygun yapı
- UI – Business Logic – Data katmanlarının ayrımı
- Kullanıcıya özel state yönetimi
- Yeniden kullanılabilir widget yapısı
- Loading, error ve empty state yönetimi

---

## ⚙️ Kurulum

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/kullaniciadi/proje_adi.git
   ```
2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
3. API anahtarınızı ve gerekli environment ayarlarını yapın.
4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```
