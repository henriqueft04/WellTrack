import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:welltrack/main.dart';

Future<void> nativeGoogleSignIn() async {

  try{ 
  const webClientId = '968120147614-765s8nced9j9qh95n3qfgkufubmdf43p.apps.googleusercontent.com';

  const iosClientId = '968120147614-765s8nced9j9qh95n3qfgkufubmdf43p.apps.googleusercontent.com';

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
    scopes: ['email', 'profile'],
  );

  await googleSignIn.signOut();

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    throw 'No Google User found.';
  }

  final googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null) {
    throw 'No Access Token found.';
  }
  if (idToken == null) {
    throw 'No ID Token found.';
  }

  await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );

  } catch (e) {
    rethrow;
  }
}