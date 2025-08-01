# 🍽️ Smart Meal & Feast Manager App


An Android application built using **Android Studio**, **Firebase Authentication**, **Firebase Firestore**, and **PDF generation**, aimed at simplifying daily meal management and feast registration for university halls.
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx.png" alt="project logo">
</p>


## 🚀 Features

### 🔹 Daily Meal Management
- Super users (hall authorities) can:
  - Add, update, and delete meals
  - Set meal types, prices, and quantities
  - Track student meal orders in real time
- Students can:
  - View available meals
  - Place meal orders easily
  - Download meal coupons as PDFs

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(1).png" alt="project logo">
</p>


### 🔹 Feast Registration & Coupon System
- Super users:
  - Add feast events with deadlines, images, and prices
  - Track feast registrations and manage coupons
- Students:
  - Register for feasts via the app
  - Receive downloadable, unique PDF coupons
  - Register only once per feast (anti-duplicate protection)
 
  - <p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(2).png" alt="project logo">
</p>



### 🔹 Anti-Fraud Mechanisms
- Prevents multiple feast registrations by the same user
- Searchable order and coupon records
- Inactive meal and feast buttons post-deadline or unavailability
  <p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(3).png" alt="project logo">
</p>

## 🛠️ Built With
- **Android Studio **
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**
- **iTextPDF / PDF generation**
- **Material Design**

  ## 🧑‍💼 User Roles

- **Superuser (Admin)**
  - Login with Firebase Auth
  - Manage meals and feasts
  - Track orders and registrations
- **Student**
  - Login with Firebase Auth
  - Order daily meals
  - Register for feasts
  - Receive PDF coupons

## 🔐 Authentication & Authorization
- Firebase Authentication used for login
- Role-based access (Superuser vs Student)
- Email/password login mechanism
- ## 🔐 Authentication (SSO)

The app uses **Firebase Authentication** with **Single Sign-On (SSO)** to manage user access securely and seamlessly.

### 🔑 Sign-In Features:
- **Google Sign-In (SSO)** is implemented using Firebase Authentication.
- Users can sign in with their university or personal Google accounts — no password required.
- User roles are determined after sign-in:
  - **Superuser (Admin):** Can add/edit meals and feasts, track orders, and manage coupons.
  - **Student:** Can place daily meal orders and register for feasts.

### ✅ Authentication Flow:
1. User logs in using **Google Sign-In**.
2. Firebase Auth handles authentication and returns a secure user ID.
3. The app fetches user role from Firestore (`Users/uid/role`) to determine access level and UI visibility.

> 🛡️ All user sessions are managed securely by Firebase. No sensitive credential data is stored in the app.

## 🗃️ Database Structure (Firestore)

```plaintext
Users/
  uid/
    - role: "student" or "superuser"
    - email
    - name

Meals/
  mealId/
    - name
    - type
    - price
    - quantity
    - imageUrl

Orders/
  orderId/
    - userId
    - items[]      # list of ordered items
    - totalPrice
    - timestamp

Feasts/
  feastId/
    - name
    - price
    - deadline
    - imageUrl
    - dateTime

Coupons/
  couponId/
    - userId
    - feastId
    - timestamp
```
## 📄 PDF Generation
- Meal and feast coupons are dynamically generated and downloadable as PDFs.
- Coupon includes:
  - Order number
  - Meal/feast details
  - Total amount
  - QR code or timestamp (optional)

## 👥 Authors
- Akila Nipo – Class Roll: 368
- Muskifus Salihin Sifat – Class Roll: 393

## 🏫 Project Info
- **Course:** Mobile Application Development Laboratory (CSE-410)
- **Department:** Computer Science and Engineering
- **University:** Jahangirnagar University
- **Supervised by:**
  - Dr. Md. Ezharul Islam (Professor)
  - Samsun Nahar Khandakar (Lecturer)

## 📦 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/SmartMealManagerApp.git
   ```
Open in Android Studio

Set up Firebase project and download google-services.json

Run the app on emulator or device

## 🖼️ Key Features

Below are some screenshots demonstrating the core functionalities of the Smart Meal & Feast Manager App:

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx.png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(1).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(2).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(3).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(4).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(5).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(6).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(7).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(8).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(9).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(10).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(11).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(12).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(13).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(14).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(15).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(16).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(17).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(18).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(19).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(20).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(21).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(22).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(23).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(24).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(25).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(26).png" alt="project logo">
</p>
<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(27).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(28).png" alt="project logo">
</p>

<p align="center">
    <img src="https://github.com/Akila-Nipo/django_temporary/blob/main/Mobile%20Application%20Development%20Laboratory.pptx%20(29).png" alt="project logo">
</p>
