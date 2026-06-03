class UserLoginDto {
  final String id;
  final String givenName;
  final String username;
  final String token;
  final String refreshToken;

  UserLoginDto({
    required this.id,
    required this.givenName,
    required this.username,
    required this.token,
    required this.refreshToken,
  });
}
