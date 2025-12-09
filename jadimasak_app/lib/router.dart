import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
import 'features/home/ui/main_wrapper.dart';
import 'features/recipes/ui/home_screen.dart';
import 'features/pantry/ui/pantry_screen.dart';
import 'features/profile/ui/profile_screen.dart';
import 'features/recipes/ui/recipe_detail_screen.dart';
import 'features/recipes/data/recipe_model.dart';
import 'features/search/ui/matching_result_screen.dart';
import 'features/auth/ui/splash_screen.dart';
import 'features/recipes/ui/saved_recipes_screen.dart';
import 'features/auth/ui/onboarding_screen.dart';
import 'features/profile/ui/edit_profile_screen.dart';
import 'features/recipes/ui/add_recipe_screen.dart';
import 'features/profile/ui/my_recipes_screen.dart';
import 'features/pantry/ui/shopping_list_screen.dart';
import 'features/profile/ui/premium_screen.dart';

// Global Key untuk navigasi (penting untuk context)
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // --- AUTH ROUTES ---
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // --- MAIN APP ROUTES (Bottom Bar) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Cabang 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Cabang 2: Kulkasku
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pantry',
              builder: (context, state) => const PantryScreen(),
            ),
          ],
        ),
        // Cabang 3: Belanja
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shopping-list',
              builder: (context, state) => const ShoppingListScreen(),
            ),
          ],
        ),

        // Cabang 4: Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    
    GoRoute(
      path: '/recipe-detail',
      builder: (context, state) {
        // Kita ambil data resep yang dikirim lewat 'extra'
        final recipe = state.extra as RecipeModel;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/search-result',
      builder: (context, state) => const MatchingResultScreen(),
    ),
    GoRoute(
      path: '/saved-recipes',
      builder: (context, state) => const SavedRecipesScreen(),
    ),

    // --- PROFILE ROUTES ---
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // --- RECIPE ROUTES ---
    GoRoute(
      path: '/add-recipe',
      builder: (context, state) => const AddRecipeScreen(),
    ),

    // --- MY RECIPES ROUTE ---
    GoRoute(
      path: '/my-recipes',
      builder: (context, state) => const MyRecipesScreen(),
    ),

    // --- EDIT RECIPE ROUTE ---
    GoRoute(
      path: '/edit-recipe',
      builder: (context, state) {
        // Ambil data resep yang dikirim
        final recipeToEdit = state.extra as RecipeModel; 
        return AddRecipeScreen(recipeToEdit: recipeToEdit);
      },
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
  ],
);