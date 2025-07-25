// ignore_for_file: non_constant_identifier_names, constant_identifier_names

const String MAIN_BASE = "https://cctv-project-production.up.railway.app/api/";
const String SECONDARY_BASE =
    "https://cctv-project-production.up.railway.app/api/";

enum ApiUrl {
  SIGN_IN("auth/login"),
  SIGN_UP("auth/register"),
  LOGOUT("auth/logout"),
  RESET_PASSWORD("auth/reset-password"),
  CCTV("cctvs"),
  ADD_CCTV("cctvs"),
  ADD_LOCATION("locations"),
  LOCATION("public/locations"),
  PROFILE("api/profile");

  final String path;

  const ApiUrl(this.path);
}
