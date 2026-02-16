Future<void> signInWithGoogle({required BuildContext context}) async {
  googleSignInLoading.value = true;

  try {
    debugPrint('=== Google Sign-In Controller Method ===');

    final GoogleSignIn googleSignIn = GoogleSignIn(



      scopes: ['email', 'profile'],





      serverClientId:
      '418880569981-1ibh3bv48t8c8tla9cudp6o5q59elg0i.apps.googleusercontent.com',






    );

    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    debugPrint('Google User: $googleUser');

    if (googleUser == null) {
      debugPrint('User cancelled Google Sign-In');
      _showAwesomeSnackbar(
        context,
        title: AppStrings.info.tr,
        message: 'Google sign-in was cancelled',
        contentType: ContentType.warning,
      );
      return;
    }

    debugPrint('SUCCESS: Google User obtained: ${googleUser.email}');

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final String? accessToken = googleAuth.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Failed to get access token from Google');
    }

    debugPrint('Sending Google token to backend...');










    Response response = await apiClient.post(
      showResult: true,
      body: {'access_token': accessToken},
      isBasic: true,
      url: ApiUrl.googleAuth.addBaseUrl,
      duration: 30,
    );








    debugPrint('Backend Response Status: ${response.statusCode}');
    debugPrint('Backend Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Clear user data but don't reset app state aggressively
      await _clearAllUserData();

      await SharedPrefsHelper.setString(
          AppConstants.fullName,
          response.body["full_name"] ??
              '${response.body["first_name"] ?? ""} ${response.body["last_name"] ?? ""}'
                  .trim());

      await SharedPrefsHelper.setString(
          AppConstants.email, response.body["email"] ?? googleUser.email);

      await SharedPrefsHelper.setString(AppConstants.image,
          response.body["image"]?.toString() ?? googleUser.photoUrl ?? "");

      await SharedPrefsHelper.setString(
          AppConstants.token, response.body["access"] ?? "");

      await SharedPrefsHelper.setString(
          AppConstants.userRole, response.body["role"] ?? "user");

      await SharedPrefsHelper.setString(
          AppConstants.refresh, response.body["refresh"] ?? "");

      await SharedPrefsHelper.setInt(
          AppConstants.userID, response.body["id"] ?? 0);

      await SharedPrefsHelper.setString(
          "test", response.body["role"] == "admin" ? "admin" : "user");

      // Initialize trial status after successful Google login
      await TrialService.initializeTrialStatus();

      debugPrint("Google login successful, navigating to home...");

      final userName = response.body["full_name"] ??
          '${response.body["first_name"] ?? ""} ${response.body["last_name"] ?? ""}'
              .trim();

      _showAwesomeSnackbar(
        context,
        title: AppStrings.welcomeTitle.tr,
        message:
        'Welcome ${userName.isNotEmpty ? userName : googleUser.displayName ?? 'User'}!',
        contentType: ContentType.success,
      );

      // Add delay and navigate without destroying controllers
      await Future.delayed(const Duration(milliseconds: 500));
      AppRouter.route.pushReplacement(RoutePath.home.addBasePath);
    } else {
      checkApi(response: response, context: context);
    }
  } catch (e) {
    debugPrint('Google Sign-In Error: $e');

    String errorMessage = e.toString();
    if (errorMessage.contains('network') ||
        errorMessage.contains('ClientException')) {
      errorMessage = 'Network error: Please check your connection';
    } else if (errorMessage.contains('PlatformException')) {
      errorMessage = 'Google Sign-In not available on this device';
    } else if (errorMessage.contains('sign_in_canceled')) {
      errorMessage = 'Sign-in was cancelled';
    } else {
      errorMessage = 'Google sign-in failed: Please try again';
    }

    _showAwesomeSnackbar(
      context,
      title: AppStrings.error.tr,
      message: errorMessage,
      contentType: ContentType.failure,
    );
  } finally {
    googleSignInLoading.value = false;
  }
}