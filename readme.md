<h1><img src="./images/Ringo-White.png" width=40 alt="logo"/> Ringo</h1>

---
## What is Ringo?
**Ringo** is an _event sharing & ticketing_ platform that allows organisations to create and share their events.  

It is user-experience focused and aims to provide a seamless experience for both the event organisers and the attendees.
Users can search for events, view event details, save events, purchase tickets and more.

The application consists of a **web app** and a [**mobile app**](https://github.com/andriikuiava/RingoFlutter). The web app is used by the event organisers to create and manage their events. 
The mobile app is used by the participants to view and purchase tickets for the events. 

The platform also provides a [**dedicated app**](https://github.com/andriikuiava/ringoqr) for scanning and validating tickets.

Some of the features of the application are:
- **Ability to build the app for both Android and iOS**
- Sign-in using Google / Apple
- Event search by distance to the user's location
- Support for multiple currencies (with automatic conversion when searching)
- Support for multiple ticket types (early bird, regular, etc.)
- Support for registration forms for events
- Users are able to review and rate organisers
- Ability to find events on the map
- Saving events, sharing them to social media including Instagram and Facebook stories as a sticker

---
## Technical aspects

> **_NOTE:_**  As we worked on Ringo as a team with my friends, this repository only contains my contributions to the project (Frontend for participants' app and [mobile scanner app](https://github.com/andriikuiava/ringoqr)).

Apps are written in Dart using the Flutter framework.
<br> 
I used different packages for different purposes, some of them are:
- [**http**](https://pub.dev/packages/http) for making HTTP requests
- [**google_maps_flutter**](https://pub.dev/packages/google_maps_flutter) for displaying maps and selecting locations in the search
- [**flutter_stripe**](https://pub.dev/packages/flutter_stripe) for processing payments
- [**url_launcher**](https://pub.dev/packages/url_launcher) for opening links in the browser
- [**google_sign_in**](https://pub.dev/packages/google_sign_in) for handling Google sign-in and authentication


Some of the features are:
- Using secure storage for storing JWT tokens, refreshing them when expired
- Storing tickets in the local storage so that they can be accessed offline
- Both dark and light mode support
- Saving events to the device's calendar

---
## Tech stack

### Backend
<table>
    <tr>
        <th>
            <a href="#"><img src="./images/java.svg" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                Java
            </span>
        </th>
        <th>
            <a href="#"><img src="./images/spring-boot.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                Spring Boot
            </span>
    </tr>
    <tr>
        <th>
            <a href="#"><img src="./images/postgres.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                PostgreSQL
            </span>
        </th>
        <th>
            <a href="#"><img src="./images/amazon-s3.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                Amazon S3
            </span>
        </th>
    </tr>
</table>

### Web apps
<table>
    <tr>
        <th>
            <a href="#"><img src="./images/javascript.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                JavaScript
            </span>
        </th>
        <th>
            <a href="#"><img src="./images/vue.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                Vue.js
            </span>
        </th>
    </tr>
</table>

### Mobile app
<table>
    <tr>
        <th>
            <a href="#"><img src="./images/flutter.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                Flutter
            </span>
        </th>
        <th>
            <a href="#"><img src="./images/dart-logo.png" width=20 height=20 alt="vue"/></a>
            <span style="color:white;font-weight:100;font-size:20px;font-family: '.AppleSystemUIFont',serif">
                Dart
            </span>
        </th>
    </tr>
</table>

---
## Screenshots

### Mobile app
<img src="./images/screenshots/Feed.png" width=400/>
<img src="./images/screenshots/Event.png" width=400/>
<img src="./images/screenshots/Event2.png" width=400/>
<img src="./images/screenshots/Search.png" width=400/>
<img src="./images/screenshots/Profile.png" width=400/>
<img src="./images/screenshots/Ticket.png" width=400/>
<img src="./images/screenshots/RegistrationForm.png" width=400/>
<img src="./images/screenshots/ContactHost.png" width=400/>
<img src="./images/screenshots/Organisation.png" width=400/>

### Ticket scanner app
<img src="./images/screenshots/ringoQR/listOfEvents.png" width=400/>
<img src="./images/screenshots/ringoQR/validTicket.png" width=400/>
<img src="./images/screenshots/ringoQR/notValidTicket.png" width=400/>

### Web app
<img src="./images/screenshots/WebLogin.jpg" width=800/><br>
<img src="./images/screenshots/WebEvents.jpg" width=800/><br>
<img src="./images/screenshots/WebProfile.jpg" width=800/><br>





