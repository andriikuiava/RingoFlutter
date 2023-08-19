class ApiEndpoints {
  static const String BASE_URL = "http://localhost:8080/api";

  //LOGIN/REGISTER
  static const String REGISTER = "$BASE_URL/participants/sign-up";
  static const String LOGIN_RINGO = "$BASE_URL/auth/login";
  static const String SIGNUP_GOOGLE = "$BASE_URL/participants/sign-up/google";
  static const String LOGIN_GOOGLE = "$BASE_URL/auth/login/google";
  static const String SIGNUP_APPLE = "$BASE_URL/participants/sign-up/apple";
  static const String LOGIN_APPLE = "$BASE_URL/auth/login/apple";
  static const String RESEND_CONFIRMATION_LINK = "$BASE_URL/auth/send-verification-email";

  //TOKENS
  static const String REFRESH_TOKENS = "$BASE_URL/auth/refresh-token";

  //USER
  static const String CURRENT_PARTICIPANT = "$BASE_URL/participants";
  static const String CHANGE_PASSWORD = "$BASE_URL/auth/change-password";
  static const String ACTIVATE_ACCOUNT = "$BASE_URL/participants/activate";
  static const String FORGOT_PASSWORD = "$BASE_URL/auth/forgot-password";

  //EVENTS
  static const String SEARCH = "$BASE_URL/events";
  static const String UNSAVE = "unsave";
  static const String SAVE = "save";
  static const String JOIN = "join";
  static const String LEAVE = "leave";
  static const String GET_TICKET = "ticket";
  static const String GET_TICKETS = "$BASE_URL/tickets";
  static const String GET_SAVED_EVENTS = "$BASE_URL/events/saved";

  //ORGANISATION
  static const String GET_ORGANISATION = "$BASE_URL/organisations";
  static const String REVIEWS = "reviews";

  //PHOTOS
  static const String GET_PHOTO = "$BASE_URL/photos";
  static const String SET_PROFILE_PICTURE = "$BASE_URL/participants/profile-picture";

  //CURRENCY & CATEGORY
  static const String GET_CURRENCY = "$BASE_URL/currencies";
  static const String GET_CATEGORY = "$BASE_URL/categories";
}