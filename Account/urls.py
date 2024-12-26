from django.urls import path
from .views import(
     RegisterStaffView, MyTokenObtainPairView,
     ChangePasswordView, TwoFactorAuthView,
     PublishListCreateView, PublishDetailView, 
     PhotoListCreateView, VideoListCreateView,DeleteAccount,
     InvestListCreateView, InvestDetailView,
     SettingsListCreateView, SettingsDetailView, 
     ProfileDetailView, UserFeedView, 
     LikePublishView, RatePublishView,
     ProfileFollowersFollowingView,
     LikeInvestView, RateInvestView,
    EnableNotificationsView,get_profile,
    EnableDarkModeView, FollowUnfollowView,
    MakeProfilePublicView, ProfileSearchView,
    ShowOnlineStatusView, UserActivityView,
    EnableTwoFactorAuthenticationView, SuggestedUsersView,
    PublishInvestSearchView, TokenRefreshViewCustom,
    EditCustomUserView, FollowersFollowingView
)



urlpatterns = [
    path('token/', MyTokenObtainPairView.as_view(), name='auth-login'),
    path('token/refresh/', TokenRefreshViewCustom.as_view(), name='token_refresh'),
    path('validate-2fa/', TwoFactorAuthView.as_view(), name='validate_2fa'),
    path('register/', RegisterStaffView.as_view(), name='auth-register'),
    path('user/<int:user_id>/change-password/', ChangePasswordView.as_view(), name='change-password'),
    path('delete_account/', DeleteAccount.as_view(), name='delete_account'),
    path('edit-profile/<int:user_id>/', EditCustomUserView.as_view(), name='edit-profile'), 
    path('profile/<int:user_id>/followers-following/', FollowersFollowingView.as_view(), name='followers-following'),
    
    path('profiles/<int:pk>/', get_profile, name='get-profile'),
    path('user/<int:user_id>/profile/<int:profile_id>/follow/', FollowUnfollowView.as_view(), name='follow-unfollow'),
    path('suggested-users/<int:user_id>/', SuggestedUsersView.as_view(), name='suggested-users'),
    path('search-profiles/', ProfileSearchView.as_view(), name='search-profiles'),
    path('search-publish-invest/', PublishInvestSearchView.as_view(), name='search-profiles'),
    path('profile/<int:user_id>/followers-following/', ProfileFollowersFollowingView.as_view(), name='profile-followers-following'),

    path('publish/', PublishListCreateView.as_view(), name='publish-list-create'),
    path('user/activity/<int:pk>/', UserActivityView.as_view(), name='user-activity'),
    path('publish/<int:pk>/', PublishDetailView.as_view(), name='publish-detail'),
    path('publish/<int:publish_id>/photos/', PhotoListCreateView.as_view(), name='photo-list-create'),
    path('publish/<int:publish_id>/videos/', VideoListCreateView.as_view(), name='video-list-create'),
    path('invest/', InvestListCreateView.as_view(), name='publish-list-create'),
    path('like/<int:id>/<int:pk>/', LikePublishView.as_view(), name='publish-like'),
    path('rate/<int:id>/<int:pk>/', RatePublishView.as_view(), name='publish-rate'),
    path('like-invest/<int:id>/<int:pk>/', LikeInvestView.as_view(), name='invest-like'),
    path('rate-invest/<int:id>/<int:user_id>/', RateInvestView.as_view(), name='invest-rate'),
    
    path('invest/<int:_id>/', InvestDetailView.as_view(), name='publish-detail'),
    path('settings/', SettingsListCreateView.as_view(), name='publish-list-create'),
    path('settings/<int:pk>/', SettingsDetailView.as_view(), name='publish-detail'),
    path('user/feed/<int:user_id>/', UserFeedView.as_view(), name='user-feed'),

    path('settings/enable-notifications/<int:pk>/', EnableNotificationsView.as_view(), name='enable-notifications'),
    path('settings/enable-dark-mode/', EnableDarkModeView.as_view(), name='enable_dark_mode'),
    path('settings/make-profile-public/<int:pk>/', MakeProfilePublicView.as_view(), name='make_profile_public'),
    path('settings/show-online-status/<int:pk>/', ShowOnlineStatusView.as_view(), name='show_online_status'),
    path('settings/enable-two-factor-authentication/<int:pk>/', EnableTwoFactorAuthenticationView.as_view(), name='enable_two_factor_authentication'),
]
