#  Online Delivery App

![Flutter](https://img.shields.io/badge/Flutter-3.13-blue) ![Dart](https://img.shields.io/badge/Dart-3.1-blue) ![License](https://img.shields.io/badge/License-MIT-green) ![Stars](https://img.shields.io/github/stars/miraalabed/online_delivery_app)

------------------------------------------------------------------------

## 📖 Overview

This is a mobile app built with **Flutter** that allows users to order food and other items from different shops. Users can choose delivery locations, pay online or on delivery, and track their orders. Admins can manage their shops and view orders easily.

------------------------------------------------------------------------

## ✨ Features

### Customer Features

* Browse shops and products
* Add items to cart and place orders
* Add items to favorites for easy access later
* Search for products by name or view shops by type (restaurant  | sweets shop | cafe) or location 
* View order history and order details

### Admin Features

* View shops linked to the admin
* Manage Shop and proudect (add, delete, update)
* Select a shop to see today's and previous orders
* Tap an order to see detailed info (customer info, items, quantity, price, notes)
* Beautiful bottom sheet UI for order details with images

### Other Features

* Signup with personal info: username, gender, date of birth, location, phone, role
* Login with email and password
* Remember Me option for faster login
* Splash screen with fade & slide animation
* Onboarding screen for first-time users
* View and update profile Info
* Form validations for email, password, phone, and other fields

------------------------------------------------------------------------

## 🖥 Screens

1. **Splash Screen** – Animated app logo.  
![Splash Screen](assets/screenshots/splash.png)

2. **Onboarding Screen** – Intro to app features.  
![Onboarding Screen](assets/screenshots/onboarding.png)

3. **Login Screen** – Login with Remember Me.  
![Login Screen](assets/screenshots/login.png)

4. **Signup Steps 1 & 2** – User registration with validations.  
   ![Signup Step 1](assets/screenshots/signup1.png)
   4.1  Signup Steps 1
 

  4.2 Signup Steps 2
  ![Signup Step 2](assets/screenshots/signup2.png)

5. **Home Screen**
  5.1 Customer Home
  ![Customer Home Screen](assets/screenshots/Customerhome.png)

  5.2 Admin Home
  ![Admin Home Screen](assets/screenshots/Adminhome.png)

6. **Product Detail Screen** – Shows product name, description, image.
   6.1 Menu Screen (Customer)
  ![Menu Screen (Customer)](assets/screenshots/Menu.png)

  6.2 Shop and Product Screen (Admin
  ![Product Screen (Admin)](assets/screenshots/Product.png)

7. **Cart Screen** – Shows selected products, total price, checkout.
   7.1 Add to Cart Screen
  ![Add to Cart Screen](assets/screenshots/addToCart.png)

  7.2 Cart Screen
  ![Cart Screen](assets/screenshots/cart.png)

8. **Favorite Screen** – Shows Favorite products.  
![Favorite Screen](assets/screenshots/Favorite.png)

9. **View Orders Screen**
   9.1 View Order (Admin)
  ![Admin](assets/screenshots/orders1.png)

  9.2 View Order (Customer)
  ![Customer](assets/screenshots/orders2.png)

10. **Profile Screen** – Login with Remember Me.
  10.1 Profile Info Screen
  ![profile info Screen](assets/screenshots/profileInfo.png)

  10.2 Edit Profile Screen
  ![profile edit Screen](assets/screenshots/profileEdit.png)



------------------------------------------------------------------------

## 🛠 Technologies Used

* **Flutter & Dart** – Frontend
* **SharedPreferences** – Store login info
* **HTTP & JSON** – Backend communication
* **PHP & MySQL** – Backend API

------------------------------------------------------------------------

## 🚀 How to Run

1. Clone this repository:

```bash
git clone https://github.com/miraalabed/online_delivery_app.git
```

2. Install dependencies:

```bash
flutter pub get
```

3. Start your local PHP server with MySQL database.
4. Run the app:

```bash
flutter run
```

> Make sure backend URLs (`http://localhost/project/...`) match your server setup.

------------------------------------------------------------------------

## 📌 Notes

* Admin and Customer roles have different screens and functionalities.
* Missing images use placeholders automatically.
* Animations improve UX (splash screen, order details bottom sheet).

------------------------------------------------------------------------

## 👤 Contact

For inquiries or contributions, feel free to reach out: 
- **Email**: miraalabed21@gmail.com
- **GitHub**: [Mira Al-Abed](https://github.com/miraalabed)

------------------------------------------------------------------------

© 2025 Online Delivery App. All rights reserved.
